# holiday.rb: Written by Tadayoshi Funaba 1998-2005
# $Id: holiday.rb 16 2006-03-17 16:09:47Z ikeda $

class Date

  def fixed?
    return false unless jd >= 2432753	# 1948-07-20/PooD
    *x = mon, mday
    (x == [ 1,  1]) or			# --01-01
    (x == [ 1, 15] and			# --01-15 (1948-07-20/1999-12-31)
     jd <= 2451544) or
    (x == [ 2, 11] and			# --02-11 (1966-12-09/PooD)
     jd >= 2439469) or
    (x == [ 4, 29]) or			# --04-29
    (x == [ 5,  3]) or			# --05-03
    (x == [ 5,  4] and			# --05-04 (2007-01-01/PooD)
     jd >= 2454102) or
    (x == [ 5,  5]) or			# --05-05
    (x == [ 7, 20] and			# --07-20 (1996-01-01/2002-12-31)
     jd >= 2450084 and
     jd <= 2452640) or
    (x == [ 9, 15] and			# --09-15 (1966-06-25/2002-12-31)
     jd >= 2439302 and
     jd <= 2452640) or
    (x == [10, 10] and			# --10-10 (1966-06-25/1999-12-31)
     jd >= 2439302 and
     jd <= 2451544) or
    (x == [11,  3]) or			# --11-03
    (x == [11, 23]) or			# --11-23
    (x == [12, 23] and			# --12-23 (1989-02-17/PooD)
     jd >= 2447575)
  end

  def self.nth_kday(n, k, y, m, sg=ITALY)
    jd = nil
    if n > 0
      1.upto 31 do |d|
	break if jd = valid_date?(y, m, d, sg)
      end
      jd -= 1
    else
      31.downto 1 do |d|
	break if jd = valid_date?(y, m, d, sg)
      end
      jd += 7
    end
    jd = (jd - (((jd - k) + 1) % 7)) + 7 * n
    new0(jd, 0, sg)
  end

  def nth_kday? (n, k)
    k == wday and self === self.class.nth_kday(n, k, year, mon, start)
  end

  def float?
    (mon ==  1 and nth_kday?(2, 1) and	# 2nd Mon, Jan (2000-01-01/PooD)
     jd >= 2451545) or
    (mon ==  7 and nth_kday?(3, 1) and	# 3nd Mon, Jul (2003-01-01/PooD)
     jd >= 2452641) or
    (mon ==  9 and nth_kday?(3, 1) and	# 3nd Mon, Sep (2003-01-01/PooD)
     jd >= 2452641) or
    (mon == 10 and nth_kday?(2, 1) and	# 2nd Mon, Oct (2000-01-01/PooD)
     jd >= 2451545)
  end

  private :fixed?, :float?

  def __deq(a, b, y)
    (a + 0.242194 * (y - 1980) - ((y - b) / 4).to_i).to_i
  end

  def __veq(y)
    case y
    when 1851..1899; a = 19.8277; b = 1983.0
    when 1900..1979; a = 20.8357; b = 1983.0
    when 1980..2099; a = 20.8431; b = 1980.0
    when 2100..2150; a = 21.8510; b = 1980.0
    else; raise ArgumentError, 'domain error'
    end
    self.class.civil_to_jd(y, 3, __deq(a, b, y))
  end

  def __aeq(y)
    case y
    when 1851..1899; a = 22.2588; b = 1983.0
    when 1900..1979; a = 23.2588; b = 1983.0
    when 1980..2099; a = 23.2488; b = 1980.0
    when 2100..2150; a = 24.2488; b = 1980.0
    else; raise ArgumentError, 'domain error'
    end
    self.class.civil_to_jd(y, 9, __deq(a, b, y))
  end

  private :__deq, :__veq, :__aeq

  def veq?
    return false unless (2432753..2506696) === jd	# 1948-07-20/2150-12-31
    jd == __veq(year)
  end

  def aeq?
    return false unless (2432753..2506696) === jd	# 1948-07-20/2150-12-31
    jd == __aeq(year)
  end

  private :veq?, :aeq?

  def sun? () wday == 0 end
  def mon? () wday == 1 end

  def nhol2? () fixed? or float? or veq? or aeq? end

  def need_subs?
    nhol2? and (sun? or (self - 1).need_subs?)
  end

  protected :sun?, :mon?, :nhol2?, :need_subs?

  def nhol32?
    if jd >= 2441785
      if jd <= 2454101				# 1973-04-12/2006-12-31
	self.mon? and (self - 1).nhol2?
      else					# 2007-01-01/PooD
	not nhol2? and (self - 1).need_subs?
      end
    end
  end

  def nhol33?
    if jd >= 2446427
      if jd <= 2454101				# 1985-12-27/2006-12-31
	not sun? and not nhol32? and
	  (self - 1).nhol2? and (self + 1).nhol2?
      else					# 2007-01-01/PooD
	not nhol2? and
	  (self - 1).nhol2? and (self + 1).nhol2?
      end
    end
  end

  def nholx?
    jd == 2436669 or			# 1959-04-10 # 16
    jd == 2447582 or			# 1989-02-24
    jd == 2448208 or			# 1990-11-12
    jd == 2449148			# 1993-06-09
  end

  private :nhol32?, :nhol33?, :nholx?

  def national_holiday?
    d = if os? then self.gregorian else self end
    d.instance_eval do nhol2? or nhol32? or nhol33? or nholx? end
  end

  def qfixed?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    *x = mon, mday
    (x == [ 1,  3] and (2405446..2432752) === jd) or	# 1873-10-14/1948-07-19
    (x == [ 1,  5] and (2405446..2432752) === jd) or	# 1873-10-14/1948-07-19
    (x == [ 1, 29] and (2405143..2405224) === jd) or	# 1872-12-15/1873-03-06
    (x == [ 1, 30] and (2405446..2419649) === jd) or	# 1873-10-14/1912-09-03
    (x == [ 2, 11] and (2405225..2432752) === jd) or	# 1873-03-07/1948-07-19
    (x == [ 4,  3] and (2405446..2432752) === jd) or	# 1873-10-14/1948-07-19
    (x == [ 4, 29] and (2424943..2432752) === jd) or	# 1927-03-03/1948-07-19
    (x == [ 7, 30] and (2419650..2424942) === jd) or	# 1912-09-04/1927-03-02
    (x == [ 8, 31] and (2419650..2424942) === jd) or	# 1912-09-04/1927-03-02
    (x == [ 9, 17] and (2405446..2407535) === jd) or	# 1873-10-14/1879-07-04
    (x == [10, 17] and (2407536..2432752) === jd) or	# 1879-07-05/1948-07-19
    (x == [10, 31] and (2419967..2424942) === jd) or	# 1913-07-18/1927-03-02
    (x == [11,  3] and (2405163..2419649) === jd) or	# 1873-01-04/1912-09-03
    (x == [11,  3] and (2424943..2432752) === jd) or	# 1927-03-03/1948-07-19
    (x == [11, 23] and (2405446..2432752) === jd) or	# 1873-10-14/1948-07-19
    (x == [12, 25] and (2424943..2432752) === jd)	# 1927-03-03/1948-07-19
  end

  private :qfixed?

  def qveq?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    jd == __veq(year)
  end

  def qaeq?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    jd == __aeq(year)
  end

  private :qveq?, :qaeq?

  def qnholx?
    jd == 2420812 or			# 1915-11-10 # 160
    jd == 2420816 or			# 1915-11-14 # 160
    jd == 2420818 or			# 1915-11-16 # 160
    jd == 2425561 or			# 1928-11-10 # 226
    jd == 2425565 or			# 1928-11-14 # 226
    jd == 2425567			# 1928-11-16 # 226
  end

  private :qnholx?

  def old_national_holiday?
    d = if os? then self.gregorian else self end
    d.instance_eval do
      qfixed? or qnholx? or
	((2407141..2432752) === jd and (qveq? or qaeq?))# 1878-06-05/1948-07-19
    end
  end

  def self.julian_easter(y, sg=ITALY)
    a = y % 4
    b = y % 7
    c = y % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    f, g = (d + e + 114).divmod(31)
    jd = civil_to_jd(y, f, g + 1, JULIAN)
    new0(jd, 0, sg)
  end

  def self.gregorian_easter(y, sg=ITALY)
    a = y % 19
    b, c = y.divmod(100)
    d, e = b.divmod(4)
    f = ((b + 8) / 25).to_i
    g = ((b - f + 1) / 3).to_i
    h = (19 * a + b - d - g + 15) % 30
    i, k = c.divmod(4)
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = ((a + 11 * h + 22 * l) / 451).to_i
    n, p = (h + l - 7 * m + 114).divmod(31)
    jd = civil_to_jd(y, n, p + 1, GREGORIAN)
    new0(jd, 0, sg)
  end

  class << self; alias_method :easter, :gregorian_easter end

  def easter?
    self ===
      (if os?
	 self.class.julian_easter(year)
       else
	 self.class.gregorian_easter(year)
       end)
  end

end

class Date

  [ %w(nhol?	national_holiday?),
    %w(qnhol?	old_national_holiday?)
  ].each do |old, new|
    module_eval <<-"end;"
      def #{old}(*args, &block)
	if $VERBOSE
	  warn("\#{caller.shift.sub(/:in .*/, '')}: " \
	       "warning: \#{self.class}\##{old} is deprecated; " \
	       "use \#{self.class}\##{new}")
	end
	#{new}(*args, &block)
      end
    end;
  end

end
