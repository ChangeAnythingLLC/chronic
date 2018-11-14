require 'helper'

class TestRepeaterDay < TestCase
  def target_time_zone
    ActiveSupport::TimeZone['America/Chicago']
  end

  def test_next_with_dst_winter_time_shift_on_begin_date
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-11-04 15:46:06') do
        current = Chronic::RepeaterDay.new(:monday)
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-11-05 00:00:00"), span.begin
        assert_equal target_time_zone.parse("2018-11-06 00:00:00"), span.end
      end
    end
  end

  def test_next_with_dst_winter_time_shift_on_end_date
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-11-03 15:46:06') do
        current = Chronic::RepeaterDay.new(:monday)
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-11-04 00:00:00"), span.begin
        assert_equal target_time_zone.parse("2018-11-05 00:00:00"), span.end
      end
    end
  end

  def test_next_with_dst_summer_time_shift_on_begin_date
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-03-11 00:06:06') do
        current = Chronic::RepeaterDay.new(:monday)
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-03-12 00:00:00"), span.begin
        assert_equal target_time_zone.parse("2018-03-13 00:00:00"), span.end
      end
    end
  end

  def test_next_with_dst_summer_time_shift_on_end_date
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-03-10 00:06:06') do
        current = Chronic::RepeaterDay.new(:monday)
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-03-11 00:00:00"), span.begin
        assert_equal target_time_zone.parse("2018-03-12 00:00:00"), span.end
      end
    end
  end
end
