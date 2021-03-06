require 'helper'

class TestRepeaterTime < TestCase

  def setup
    # Wed Aug 16 14:00:00 2006
    @now = Time.local(2006, 8, 16, 14, 0, 0, 0)
  end

  def test_generic
    assert_raises(ArgumentError) do
      Chronic::RepeaterTime.new('00:01:02:03:004')
    end
  end

  def target_time_zone
    ActiveSupport::TimeZone['America/Chicago']
  end

  def test_next_future
    t = Chronic::RepeaterTime.new('4:00')
    t.start = @now

    assert_equal Time.local(2006, 8, 16, 16), t.next(:future).begin
    assert_equal Time.local(2006, 8, 17, 4), t.next(:future).begin

    t = Chronic::RepeaterTime.new('13:00')
    t.start = @now

    assert_equal Time.local(2006, 8, 17, 13), t.next(:future).begin
    assert_equal Time.local(2006, 8, 18, 13), t.next(:future).begin

    t = Chronic::RepeaterTime.new('0400')
    t.start = @now

    assert_equal Time.local(2006, 8, 17, 4), t.next(:future).begin
    assert_equal Time.local(2006, 8, 18, 4), t.next(:future).begin

    t = Chronic::RepeaterTime.new('0000')
    t.start = @now

    assert_equal Time.local(2006, 8, 17, 0), t.next(:future).begin
    assert_equal Time.local(2006, 8, 18, 0), t.next(:future).begin
  end

  def test_next_future_with_dst_winter_time_shift
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-11-03 15:46:06') do
        current = Chronic::RepeaterTime.new('03:30')
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-11-04 03:30:00"), span.begin
        assert_equal target_time_zone.parse("2018-11-04 03:30:01"), span.end
      end
    end
  end

  def test_next_future_with_dst_summer_time_shift
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-03-11 00:06:06') do
        current = Chronic::RepeaterTime.new('00:30')
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-03-11 00:30:00"), span.begin
        assert_equal target_time_zone.parse("2018-03-11 00:30:01"), span.end
      end
    end
  end

  def test_next_past_with_dst_winter_time_shift
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-11-03 15:46:06') do
        current = Chronic::RepeaterTime.new('04:30')
        current.start = target_time_zone.now

        span = current.next(:future)

        assert_equal target_time_zone.parse("2018-11-04 04:30:00"), span.begin
        assert_equal target_time_zone.parse("2018-11-04 04:30:01"), span.end
      end
    end
  end

  def test_next_past_with_dst_summer_time_shift
    Chronic.stub(:time_class, target_time_zone) do
      travel_to target_time_zone.parse('2018-03-11 07:06:06') do
        current = Chronic::RepeaterTime.new('00:30')
        current.start = target_time_zone.now

        span = current.next(:past)

        assert_equal target_time_zone.parse("2018-03-11 00:30:00"), span.begin
        assert_equal target_time_zone.parse("2018-03-11 00:30:01"), span.end
      end
    end
  end

  def test_next_past
    t = Chronic::RepeaterTime.new('4:00')
    t.start = @now

    assert_equal Time.local(2006, 8, 16, 4), t.next(:past).begin
    assert_equal Time.local(2006, 8, 15, 16), t.next(:past).begin

    t = Chronic::RepeaterTime.new('13:00')
    t.start = @now

    assert_equal Time.local(2006, 8, 16, 13), t.next(:past).begin
    assert_equal Time.local(2006, 8, 15, 13), t.next(:past).begin

    t = Chronic::RepeaterTime.new('0:00.000')
    t.start = @now

    assert_equal Time.local(2006, 8, 16, 0), t.next(:past).begin
    assert_equal Time.local(2006, 8, 15, 0), t.next(:past).begin
  end

  def test_type
    t1 = Chronic::RepeaterTime.new('4')
    assert_equal 14_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('14')
    assert_equal 50_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('4:00')
    assert_equal 14_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('4:30')
    assert_equal 16_200, t1.type.time

    t1 = Chronic::RepeaterTime.new('1400')
    assert_equal 50_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('0400')
    assert_equal 14_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('04')
    assert_equal 14_400, t1.type.time

    t1 = Chronic::RepeaterTime.new('400')
    assert_equal 14_400, t1.type.time
  end

end
