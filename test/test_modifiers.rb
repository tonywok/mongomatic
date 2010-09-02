require 'helper'

class TestModifiers < Test::Unit::TestCase
  def setup
    Person.collection.drop
  end
  
  should "be able to push" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    assert p1.push("interests", "skydiving")
    assert p1["interests"].include?("skydiving")
    p1 = Person.find_one(p1["_id"])
    assert p1["interests"].include?("skydiving")
    assert p1.push!("interests", "coding")
    assert p1["interests"].include?("coding")
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving","coding"], p1["interests"]
    
    p1["interests"] = "foo"
    assert_raise(Mongomatic::Modifiers::UnexpectedFieldType) { p1.push("interests", "snowboarding") }
  end
  
  should "be able to push on a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    assert p1.push!("personal.interests", "skydiving")
    assert_equal ["skydiving"], p1["personal"]["interests"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving"], p1["personal"]["interests"]
  end
  
  should "be able to push_all" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    assert p1.push("interests", "skydiving")
    assert p1["interests"].include?("skydiving")
    p1 = Person.find_one(p1["_id"])
    assert p1["interests"].include?("skydiving")
   
    assert p1.push_all!("interests", ["coding","running","snowboarding","reading"])
    assert_equal ["skydiving","coding","running","snowboarding","reading"], p1["interests"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving","coding","running","snowboarding","reading"], p1["interests"]
    
    p1["interests"] = "foo"
    assert_raise(Mongomatic::Modifiers::UnexpectedFieldType) { p1.push_all("interests", ["snowboarding"]) }
  end
  
  should "be able to push_all on a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    p1.push_all!("contacts.coworkers", ["Chris","Keith","Jordan","Mike"])
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
  end
  
  should "be able to pull" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    assert p1.push("interests", "skydiving")
    assert p1.push_all!("interests", ["coding","running","snowboarding","reading"])
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving","coding","running","snowboarding","reading"], p1["interests"]
    assert p1.pull!("interests", "running")
    assert_equal ["skydiving","coding","snowboarding","reading"], p1["interests"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving","coding","snowboarding","reading"], p1["interests"]
   
    p1["interests"] = "foo"
    assert_raise(Mongomatic::Modifiers::UnexpectedFieldType) { p1.pull("interests", ["snowboarding"]) }
  end
  
  should "be able to pull on a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    p1.insert!
    p1.push_all!("contacts.coworkers", ["Chris","Keith","Jordan","Mike","Joe"])
    assert_equal ["Chris","Keith","Jordan","Mike","Joe"], p1["contacts"]["coworkers"]
    p1.pull!("contacts.coworkers", "Joe")
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
  end
  
  should "be able to pull_all" do
    p1 = Person.new(:name => "Jordan")
    p1.insert
    assert p1.push_all!("interests", ["skydiving", "coding","running","snowboarding","reading"])
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving","coding","running","snowboarding","reading"], p1["interests"]
    p1.pull_all!("interests", ["running", "snowboarding"])
    assert_equal ["skydiving", "coding","reading"], p1["interests"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["skydiving", "coding","reading"], p1["interests"]
   
    p1["interests"] = "foo"
    assert_raise(Mongomatic::Modifiers::UnexpectedFieldType) { p1.pull_all("interests", ["snowboarding"]) }
  end
  
  should "be able to pull_all on a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    p1.insert!
    p1.push_all!("contacts.coworkers", ["Chris","Jim","Keith","Jordan","Mike","Joe"])
    assert_equal ["Chris","Jim","Keith","Jordan","Mike","Joe"], p1["contacts"]["coworkers"]
    p1.pull_all!("contacts.coworkers", ["Joe","Jim"])
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["Chris","Keith","Jordan","Mike"], p1["contacts"]["coworkers"]
  end
  
  should "be able to inc" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    p1["count1"] = 5
    assert p1.update!
    assert p1.inc!("count1", 3)
    assert p1.inc!("count2", -4)
    assert_equal 8, p1["count1"]
    assert_equal -4, p1["count2"]
    p1 = Person.find_one(p1["_id"])
    assert_equal 8, p1["count1"]
    assert_equal -4, p1["count2"]
  end
  
  should "be able to inc a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    p1.inc!("counters.visitors", 10)
    p1.inc!("level1.level2.level3.counter", 20)
    assert_equal 10, p1["counters"]["visitors"]
    assert_equal 20, p1["level1"]["level2"]["level3"]["counter"]
    p1 = Person.find_one(p1["_id"])
    assert_equal 10, p1["counters"]["visitors"]
    assert_equal 20, p1["level1"]["level2"]["level3"]["counter"]
  end
  
  should "be able to set" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    assert p1.set!("foo", "bar")
    assert_equal "bar", p1["foo"]
    p1 = Person.find_one(p1["_id"])
    assert_equal "bar", p1["foo"]
  end
  
  should "be able to set a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    p1.set!("l1.l2.l3.l4.name", "Ben")
    assert_equal "Ben", p1["l1"]["l2"]["l3"]["l4"]["name"]
    p1 = Person.find_one(p1["_id"])
    assert_equal "Ben", p1["l1"]["l2"]["l3"]["l4"]["name"]
  end
  
  should "be able to unset" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    assert p1.set!("foo", "bar")
    assert_equal "bar", p1["foo"]
    p1 = Person.find_one(p1["_id"])
    assert_equal "bar", p1["foo"]
    
    assert p1.unset!("foo")
    assert p1["foo"].nil?
    p1 = Person.find_one(p1["_id"])
    assert p1["foo"].nil?
  end
  
  should "be able to unset a field in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    p1.set!("l1.l2.l3.l4.name", "Ben")
    assert_equal "Ben", p1["l1"]["l2"]["l3"]["l4"]["name"]
    p1 = Person.find_one(p1["_id"])
    assert_equal "Ben", p1["l1"]["l2"]["l3"]["l4"]["name"]
    assert p1["l1"]["l2"]["l3"]["l4"].has_key?("name")

    p1.unset!("l1.l2.l3.l4.name")
    assert_equal nil, p1["l1"]["l2"]["l3"]["l4"]["name"]
    assert !p1["l1"]["l2"]["l3"]["l4"].has_key?("name")
    
    p1 = Person.find_one(p1["_id"])
    assert_equal nil, p1["l1"]["l2"]["l3"]["l4"]["name"]
    assert !p1["l1"]["l2"]["l3"]["l4"].has_key?("name")
  end
  
  should "be able to add_to_set" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    
    assert p1.add_to_set!("hot_colors", "red")
    assert p1.add_to_set!("cold_colors", ["grey","blue"])
    
    assert_equal ["red"], p1["hot_colors"]
    assert_equal ["grey","blue"], p1["cold_colors"]
    
    p1 = Person.find_one(p1["_id"])

    assert_equal ["red"], p1["hot_colors"]
    assert_equal ["grey","blue"], p1["cold_colors"]
  end
  
  should "be able to add_to_set in an embedded hash" do
    p1 = Person.new(:name => "Jordan")
    assert p1.insert!
    p1.add_to_set!("colors.hot", ["red", "pink", "orange"])
    assert_equal ["red", "pink", "orange"], p1["colors"]["hot"]
    p1 = Person.find_one(p1["_id"])
    assert_equal ["red", "pink", "orange"], p1["colors"]["hot"]
  end
  
  should "be able to pop_last" do
    p1 = Person.new(:name => "Jordan")
    p1["numbers"] = [1,2,3,4,5]
    assert p1.insert!
    p1.pop_last!("numbers")
    assert_equal [1,2,3,4], p1["numbers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal [1,2,3,4], p1["numbers"]
  end
  
  should "be able to pop_last in an embedded doc" do
    p1 = Person.new(:name => "Jordan")
    p1["stats"] = { "numbers" => [1,2,3,4,5] }
    assert p1.insert!
    p1.pop_last!("stats.numbers")
    assert_equal [1,2,3,4], p1["stats"]["numbers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal [1,2,3,4], p1["stats"]["numbers"]
  end
  
  should "be able to pop_first" do
    p1 = Person.new(:name => "Jordan")
    p1["numbers"] = [1,2,3,4,5]
    assert p1.insert!
    p1.pop_first!("numbers")
    assert_equal [2,3,4,5], p1["numbers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal [2,3,4,5], p1["numbers"]
  end
  
  should "be able to pop_first in an embedded doc" do
    p1 = Person.new(:name => "Jordan")
    p1["stats"] = { "numbers" => [1,2,3,4,5] }
    assert p1.insert!
    p1.pop_first!("stats.numbers")
    assert_equal [2,3,4,5], p1["stats"]["numbers"]
    p1 = Person.find_one(p1["_id"])
    assert_equal [2,3,4,5], p1["stats"]["numbers"]
  end
  
end