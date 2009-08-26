class ReportsController < ApplicationController

  # To make caching easier, add a line like this to config/routes.rb:
  # map.graph "graph/:action/:id/image.png", :controller => "graph"
  #
  # Then reference it with the named route:
  #   image_tag graph_url(:action => 'show', :id => 42)

  class ChartBase
    def initialize(params)
      @params = params
      @gruff = Gruff::Line.new(400)
      @title = "(変更してください)"
      @debug = false
      @limit_person = 5
      set_font
      set_colors
    end

    def set_font
      [
        "#{RAILS_ROOT}/lib/Vera.ttf",
        "/usr/share/fonts/ja/TrueType/kochi-gothic.ttf",
        "/opt/openoffice.org2.0/share/fonts/truetype/Vera.ttf",
        "/usr/share/fonts/ja/TrueType/kochi-gothic-subst.ttf",
        "/home/ikeda/kochi-gothic.ttf",
      ].each{|font_file|
        RAILS_DEFAULT_LOGGER.info("#{font_file} exist?")
        font_file = Pathname(font_file).expand_path
        if font_file.exist?
          @ttf_font = font_file
          break
        end
      }
      RAILS_DEFAULT_LOGGER.info("@ttf_font = #{@ttf_font}")
    end

    def set_colors
      @gruff.instance_eval{
        reset_themes()

        # soft
        @green  = '#79d38f'
        @purple = '#a679d3'
        @blue   = '#798fd3'
        @yellow = '#d3d379'
        @red    = '#d37979'
        @orange = '#d3a679'     # 30度
        @black  = '#333333'     # 適当

        @colors = [@blue, @red, @green, @orange, @yellow, @purple, @black]
        @marker_color = Palette[1];
        @base_image = render_gradiated_background('white', 'white')
      }
    end

    def plot
      if @ttf_font && @ttf_font.exist?
        @gruff.font = @ttf_font.to_s
      end

      @gruff.title = @title

      target_users.each{|user|
        @gruff.data(user.loginname, build_graph(user))
      }

      @gruff.labels = build_labels
    end

    # 指定期間内の投稿数が多い順にユーザーを@limit_person人特定する。
    # mysql -u root memo_station_development -e "select users.id,count(*) as count_all from articles, users where articles.user_id = users.id group by users.id order by count_all desc"
    # +----+-----------+
    # | id | count_all |
    # +----+-----------+
    # |  2 |        24 |
    # |  4 |         3 |
    # +----+-----------+
    def target_users
      if false
        # Ruby版
        users = User.find(:all).find_all{|user|
          user.articles.to_a.find{|article|
            @date_range.include?(article.created_at.to_date)
          }
        }
        users = users.sort_by{|user|user.articles.count}.reverse
        users.first(@limit_person)
      else
        # SQL版
        user_id_with_count_ary = Article.count(:conditions => "created_at #{@date_range.to_s(:db)}", :group => :user_id, :order => "count_all DESC", :limit => @limit_person)
        RAILS_DEFAULT_LOGGER.debug(user_id_with_count_ary.inspect)
        user_ids = user_id_with_count_ary.map{|user_id, count|user_id}
        users = user_ids.map{|user_id|User.find(user_id)}
      end
      RAILS_DEFAULT_LOGGER.debug(users.map{|user|user.id}.inspect)
      users
    end

    def to_blob
      plot
      RAILS_DEFAULT_LOGGER.debug("to_blog: #{@gruff.title}")
      @gruff.to_blob
    end

    # ラベルの作成
    # 使う方は文字列で日付フォーマットを返すだけでよい
    def label_maker
      labels = {}
      date_range_each{|date, index|
        if format = yield(date)
          labels.update date_label_set(index, date, format)
        end
      }
      labels
    end

    # 日付のイテレータ
    def date_range_each
      raise "サブクラスで date_range_each を実装してください。"
    end

    private

    # ラベルの作成
    def date_label_set(index, date, format)
      label = date.to_time.strftime(format)
      RAILS_DEFAULT_LOGGER.debug("label: #{label}")
      {index => label}
    end
  end

  class DailyChart < ChartBase
    def initialize(*)
      super
      @title = "Daily Chart"
      if @debug
        @date_range = ("2006-05-01".to_time .. "2006-06-01".to_time)
      else
        @date_range = Time.now.beginning_of_day.months_ago(1) .. Time.now
      end
    end

    def build_graph(user)
      # ユーザー(user)の日付(created_on)あたりの投稿数(count)を取得する
      date_infos = user.articles.find(:all, :select => "month(created_at) as month, day(created_at) as day, count(*) AS count", :conditions => "created_at #{@date_range.to_s(:db)}", :group => "month(created_at), day(created_at)")
      RAILS_DEFAULT_LOGGER.debug(date_infos.inspect)
      distribution = []
      # 日付(day)を順番に進めて行ってdate_infosにその日付が入っていればその日(created_on)の投稿数(count)を取得する
      date_range_each{|date, index|
        # date_infosにその日付の情報があるか？
        if find = date_infos.find{|date_info|
            date.month == date_info.month.to_i && date.day == date_info.day.to_i
          }
          distribution << find.count.to_i
        else
          if user.created_at.beginning_of_day <= date.to_time
            distribution << 0
          else
            # その人はまだ会員登録していない状態だったので線を書きたくない場合はここで nil を設定する
            distribution << 0
          end
        end
        # 日付順に投稿数を記録
        RAILS_DEFAULT_LOGGER.debug("ユーザー:#{user.loginname} 日付:#{date} 投稿数:#{distribution.last}")
      }
      distribution
    end

    # 月曜日だけにラベルを付ける
    def build_labels
      label_maker{|date|
        if date.wday == 1
          "%m/%d"
        end
      }
    end

    def date_range_each
      (@date_range.begin.to_date .. @date_range.end.to_date).each_with_index{|date, index|
        yield date, index
      }
    end
  end

  class WeeklyChart < ChartBase
    def initialize(*)
      super
      @title = "Weekly Chart"
      if @debug
        @date_range = ("2005-06-01".to_time .. "2006-08-01".to_time)
      else
        @date_range = (Time.now.beginning_of_week - 24.weeks) .. Time.now.beginning_of_week
      end
      RAILS_DEFAULT_LOGGER.debug(@date_range.to_s(:db).inspect)
    end

    def build_graph(user)
      # ユーザー(user)の月毎の投稿数(count)を取得する
      date_infos = user.articles.find(:all, :select => "year(created_at) as year, week(created_at,7) as week, count(*) AS count", :conditions => "created_at #{@date_range.to_s(:db)}", :group => "year(created_at), week(created_at,7)")
      RAILS_DEFAULT_LOGGER.debug(date_infos.inspect)
      distribution = []
      # 日付(day)を順番に進めて行ってdate_infosにその日付が入っていればその日(created_on)の投稿数(count)を取得する
      date_range_each{|date, index|
        # date_infosにその日付の情報があるか？
        if find = date_infos.find{|date_info|
            date.year == date_info.year.to_i && date.to_date.cweek.to_i == date_info.week.to_i
          }
          distribution << find.count.to_i
        else
          if user.created_at.beginning_of_week <= date
            distribution << 0
          else
            distribution << nil
          end
        end
        # 日付順に投稿数を記録
        RAILS_DEFAULT_LOGGER.debug("ユーザー:#{user.loginname} 日付:#{date}(#{date.to_date.cweek}週) 投稿数:#{distribution.last}")
      }
      distribution
    end

    def build_labels
      label_maker{|date|
        if date.day <= (1.week / 1.day)
          "%m"
        end
      }
    end

    private

    def date_range_each
      date = @date_range.begin
      index = 0
      begin
        yield date, index
        date = date.next_week
        index += 1
      end until date == @date_range.end.next_week
    end
  end

  class MonthlyChart < ChartBase
    def initialize(*)
      super
      @title = "Monthly Chart"
      if @debug
        @date_range = ("2005-06-01".to_time .. "2006-08-01".to_time)
      else
        @date_range = Time.now.beginning_of_month.ago(24.months) .. Time.now.end_of_month
      end
      RAILS_DEFAULT_LOGGER.debug(@date_range.to_s(:db).inspect)
    end

    def build_graph(user)
      # ユーザー(user)の月毎の投稿数(count)を取得する
      date_infos = user.articles.find(:all, :select => "year(created_at) as year, month(created_at) as month, count(*) AS count", :conditions => "created_at #{@date_range.to_s(:db)}", :group => "year(created_at), month(created_at)")
      RAILS_DEFAULT_LOGGER.debug(date_infos.inspect)
      distribution = []
      # 日付(day)を順番に進めて行ってdate_infosにその日付が入っていればその日(created_on)の投稿数(count)を取得する
      date_range_each{|date, index|
        # date_infosにその日付の情報があるか？
        if find = date_infos.find{|date_info|
            date.year == date_info.year.to_i && date.month == date_info.month.to_i
          }
          distribution << find.count.to_i
        else
          if user.created_at.beginning_of_day <= date
            distribution << 0
          else
            distribution << nil
          end
        end
        # 日付順に投稿数を記録
        RAILS_DEFAULT_LOGGER.debug("ユーザー:#{user.loginname} 日付:#{date} 投稿数:#{distribution.last}")
      }
      distribution
    end

    # 年始めだけ年を入れる
    def build_labels
      label_maker{|date|
        if date.month == 1
          "%Y/%m"
        elsif date.month.modulo(6) == 0
          "%m"
        end
      }
    end

    private

    def date_range_each
      base_date = @date_range.begin.beginning_of_month
      index = 0
      begin
        date = base_date.months_since(index)
        yield date, index
        index += 1
      end until date == @date_range.end.beginning_of_month
    end
  end

  def show
    graph_klass = self.class.const_get("#{params[:type].capitalize}Chart")
    graph_obj = graph_klass.new(params)
    send_data(graph_obj.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "gruff.png")
  end

  # ... Use inside any controller

  # Send a graph to the browser
  def line_graph_report
    g = Gruff::Line.new(400)
    g.title = "Scores for Bart"
    g.font = File.expand_path('artwork/fonts/Vera.ttf', RAILS_ROOT)
    g.labels = { 0 => 'Mon', 2 => 'Wed', 4 => 'Fri', 6 => 'Sun' }

    # Modify this to represent your actual data models
    @data = Data.find(:all)
    @data.each do |d|
      # Build data into array with something like
      # built_array = d.collect { |e| e.some_number_field.to_f }
      g.data(some_label, built_array)
    end

    send_data(g.to_blob,
              :disposition => 'inline',
              :type => 'image/png',
              :filename => "bart_scores.png")
  end
end
