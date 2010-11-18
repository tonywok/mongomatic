require 'helper'
require 'minitest/autorun'

class MyCoolCallbacks < Mongomatic::Observer
end

class ThingObserver < Mongomatic::Observer
end

class FoobarObserver < Mongomatic::Observer
  class << self
    attr_accessor :observable_instance
    
    def observer_tests
      @observer_tests || []
    end
  
    def add_observer_test_val(val)
      @observer_tests ||= []
      @observer_tests << val
    end
  end
  
  def before_validate(instance)
    self.class.observable_instance = instance
    self.class.add_observer_test_val(:before_validate)
  end
  
  def after_validate(instance)
    self.class.add_observer_test_val(:after_validate)
  end
  
  def before_insert(instance)
    self.class.add_observer_test_val(:before_insert)
  end
  
  def before_insert_or_update(instance)
    self.class.add_observer_test_val(:before_insert_or_update)
  end
  
  def after_insert_or_update(instance)
    self.class.add_observer_test_val(:after_insert_or_update)
  end
  
  def after_insert(instance)
    self.class.add_observer_test_val(:after_insert)
  end

  def before_update(instance)
    self.class.add_observer_test_val(:before_update)
  end
  
  def after_update(instance)
    self.class.add_observer_test_val(:after_update)
  end
  
  def before_remove(instance)
    self.class.add_observer_test_val(:before_remove)
  end
  
  def after_remove(instance)
    self.class.add_observer_test_val(:after_remove)
  end
end

class TestObservable < MiniTest::Unit::TestCase
  def test_add_observer_to_class
    Person.send(:include, Mongomatic::Observable)

    assert_equal [], Person.observers
    
    Person.add_observer(MyCoolCallbacks)
    assert_equal Person.observers, [MyCoolCallbacks]
  end
  
  
  def test_add_observer_to_class_when_class_is_inferred_and_module_included_post_load
    assert_equal [RigObserver], Rig.observers
  end
  
  def test_add_observer_to_class_when_class_is_inferred_and_module_included_pre_load
    assert_equal [FoobarObserver], Foobar.observers
  end
  
  def test_passes_instance_to_observer
    f = Foobar.new
    f.valid?
    
    assert_equal f, FoobarObserver.observable_instance
  end
  
  def test_before_validate
    f = Foobar.new
    f.valid?
    
    assert FoobarObserver.observer_tests.include?(:before_validate)
  end
  
  def test_after_validate
    f = Foobar.new
    f.valid?
    
    assert FoobarObserver.observer_tests.include?(:after_validate)
  end
  
  def test_before_insert
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    
    assert FoobarObserver.observer_tests.include?(:before_insert)
  end
  
  def test_after_insert
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    
    assert FoobarObserver.observer_tests.include?(:after_insert)
  end
  
  def test_before_insert_or_update
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    
    assert FoobarObserver.observer_tests.include?(:before_insert_or_update)
  end
  
  def test_after_insert_or_update
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    
    assert FoobarObserver.observer_tests.include?(:after_insert_or_update)
  end
  
  def test_before_update
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    f.update
    
    assert FoobarObserver.observer_tests.include?(:before_update)
  end
  
  def test_after_update
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    f.update
    
    assert FoobarObserver.observer_tests.include?(:after_update)
  end
  
  def test_before_remove
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    f.remove
    
    assert FoobarObserver.observer_tests.include?(:before_remove)
  end
  
  def test_after_remove
    f = Foobar.new('style' => 'cool', 'color' => 'green')
    f.insert
    f.remove
    
    assert FoobarObserver.observer_tests.include?(:after_remove)
  end
end