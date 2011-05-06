Factory.define :user do |u|
  u.name "John Doe"
  u.sequence(:email) {|n| "foo#{n}@example.com" }
  u.password "asdf1234"
  u.password_confirmation "asdf1234"
end
Factory.define :protocol do |p|
  p.sequence(:name) {|n| "Protocol Number #{n}"}
  p.introduction "Lorem ipsum dolor sit amet. " * 10
  p.association :user
end