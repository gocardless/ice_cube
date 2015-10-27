require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule, 'to_s' do

  before :each do
    I18n.locale = :fr
  end

  it 'should represent its start time by default' do
    t0 = Time.local(2013, 2, 14)
    IceCube::Schedule.new(t0).to_s.should == '14 février 2013'
  end

  it 'should have a useful base to_s representation for a secondly rule' do
    IceCube::Rule.secondly.to_s.should == 'chaque seconde'
    IceCube::Rule.secondly(2).to_s.should == 'toutes les 2 secondes'
  end

  it 'should have a useful base to_s representation for a minutely rule' do
    IceCube::Rule.minutely.to_s.should == 'chaque minute'
    IceCube::Rule.minutely(2).to_s.should == 'toutes les 2 minutes'
  end

  it 'should have a useful base to_s representation for a hourly rule' do
    IceCube::Rule.hourly.to_s.should == 'chaque heure'
    IceCube::Rule.hourly(2).to_s.should == 'toutes les 2 heures'
  end

  it 'should have a useful base to_s representation for a daily rule' do
    IceCube::Rule.daily.to_s.should == 'chaque jour'
    IceCube::Rule.daily(2).to_s.should == 'tous les 2 jours'
  end

  it 'should have a useful base to_s representation for a weekly rule' do
    IceCube::Rule.weekly.to_s.should == 'chaque semaine'
    IceCube::Rule.weekly(2).to_s.should == 'toutes les 2 semaines'
  end

  it 'should have a useful base to_s representation for a monthly rule' do
    IceCube::Rule.monthly.to_s.should == 'chaque mois'
    IceCube::Rule.monthly(2).to_s.should == 'tous les 2 mois'
  end

  it 'should have a useful base to_s representation for a yearly rule' do
    IceCube::Rule.yearly.to_s.should == 'chaque année'
    IceCube::Rule.yearly(2).to_s.should == 'tous les 2 ans'
  end

  it 'should work with various sentence types properly' do
    IceCube::Rule.weekly.to_s.should == 'chaque semaine'
    IceCube::Rule.weekly.day(:monday).to_s.should == 'chaque lundi'
    IceCube::Rule.weekly.day(:monday, :tuesday).to_s.should == 'chaque lundi et mardi'
    IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'chaque lundi, mardi, et mercredi'
  end

  it 'should show saturday and sunday as weekends' do
    IceCube::Rule.weekly.day(:saturday, :sunday).to_s.should == 'chaque weekend'
  end

  it 'should not show saturday and sunday as weekends when other days are present also' do
    IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s.should ==
      'chaque dimanche, lundi, et samedi'
  end

  it 'should reorganize days to be in order' do
    IceCube::Rule.weekly.day(:tuesday, :monday).to_s.should ==
      'chaque lundi et mardi'
  end

  it 'should show weekdays as such' do
    IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'tous les jours de semaine'
  end

  it 'should not show weekdays as such when a weekend day is present' do
    IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'chaque dimanche, lundi, mardi, mercredi, jeudi, et vendredi'
  end

  it 'should show start time for an empty schedule' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.to_s.should == "20 mars 2010"
  end

  it 'should work with a single date' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == "20 mars 2010"
  end

  it 'should work with additional dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    schedule.to_s.should == '20 mars 2010 / 21 mars 2010'
  end

  it 'should order dates that are out of order' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    schedule.to_s.should == '19 mars 2010 / 20 mars 2010'
  end

  it 'should remove duplicated start time' do
    schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
    schedule.add_recurrence_time t0
    schedule.to_s.should == '20 mars 2010'
  end

  it 'should remove duplicate rtimes' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == '19 mars 2010 / 20 mars 2010'
  end

  it 'should work with rules and dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.to_s.should == '20 mars 2010 / chaque semaine'
  end

  it 'should work with rules and times and exception times' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_time Time.local(2010, 3, 20) # ignored
    schedule.add_exception_time Time.local(2010, 3, 21)
    schedule.to_s.should == 'chaque semaine / sauf le 20 mars 2010 / sauf le 21 mars 2010'
  end

  it 'should work with a single rrule' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1])
    schedule.to_s.should == schedule.rrules[0].to_s
  end

  it 'should be able to say the last Thursday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-1]).to_s
    rule_str.should == 'tous les derniers jeudis du mois'
  end

  it 'should be able to say what months of the year something happens' do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    rule_str.should == 'chaque année en juin et juillet'
  end

  it 'should be able to say the second to last monday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-2]).to_s
    rule_str.should == 'tous les avant-derniers jeudis du mois'
  end

  it 'should join the first and last weekdays of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [1, -1]).to_s
    rule_str.should == 'tous les 1ers jeudis et derniers jeudis du mois'
  end

  it 'should be able to say the days of the month something happens' do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    rule_str.should == 'les 1ers, 15, et 30 du mois'
  end

  it 'should be able to say what day of the year something happens' do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    rule_str.should == "le 30e jour de l'année"
  end

  it 'should be able to say what hour of the day something happens' do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    rule_str.should == 'chaque jour à 6 et 12 heures'
  end

  it 'should be able to say what minute of an hour something happens - with special suffix minutes' do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    rule_str.should == 'chaque heure aux 10e, 11e, 12e, 13e, 14e, et 15e minutes de chaque heure'
  end

  it 'should be able to say what seconds of the minute something happens' do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    rule_str.should == 'chaque minute aux 10e et 11er secondes de chaque minute'
  end

  it 'should be able to reflect until dates' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    schedule.to_s.should == "chaque semaine jusqu'au 3 février 2012"
  end

  it 'should be able to reflect count' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    schedule.to_s.should == '1 fois par semaine'
  end

  it 'should be able to reflect count (proper pluralization)' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    schedule.to_s.should == '2 fois par semaine'
  end

end
