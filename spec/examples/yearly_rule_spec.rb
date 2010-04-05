require File.dirname(__FILE__) + '/spec_helper'

describe YearlyRule, 'occurs_on?' do

  it 'should be able to specify complex yearly rules' do
    start_date = Time.local(2010, 7, 12, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:april).day_of_week(:monday => [1, -1])
    #check assumption - over 1 year should be 2
    schedule.occurrences(start_date + TimeUtil.days_in_year(start_date) * IceCube::ONE_DAY).count.should == 2
  end
  
  it 'should produce the correct number of days for @interval = 1' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly
    #check assumption
    schedule.occurrences(start_date + 370 * IceCube::ONE_DAY).count.should == 2
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly(2)
    #check assumption
    schedule.occurrences(start_date + 370 * IceCube::ONE_DAY).count.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 when you specify months' do
    start_date = Time.utc(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:january, :april, :november)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).count.should == 3
  end

  it 'should produce the correct number of days for @interval = 1 when you specify days' do
    start_date = Time.utc(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly.day_of_year(155, 200)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).count.should == 2
  end

  it 'should produce the correct number of days for @interval = 1 when you specify negative days' do
    schedule = Schedule.new(Time.utc(2010, 1, 1))
    schedule.add_recurrence_rule Rule.yearly.day_of_year(100, -1)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).count.should == 2
  end
  
end
