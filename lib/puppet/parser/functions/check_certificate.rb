#
# check_certificate.rb
#
# Copyright 2016 Bernd Zeimetz
#
# Based on exists.rb:
# Copyright 2012 Krzysztof Wilczynski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Puppet::Parser::Functions
  newfunction(:check_certificate, :type => :rvalue, :doc => <<-EOS
    Checks if a certificate file exists for now.
    Needs expire time and other useful checks.
    FIXME!
    EOS
  ) do |*args|
    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively form a template it will always
    # do the right thing ...
    #
    args = args.shift if args.first.is_a?(Array)

    raise Puppet::ParseError, "exists(): Wrong number of args " +
      "given (#{args.size} for 1)" if args.size < 1

    file = args.shift

    raise Puppet::ParseError, 'exists(): Requires a string type ' +
      'to work with' unless file.is_a?(String)

    # We want to be sure that we have the complete path ...
    file = File.expand_path(file)

    File.exists?(file)
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
