# encoding: utf-8

require 'functional/helper'

describe 'inputs' do
  include FunctionalHelper
  let(:inputs_profiles_path) { File.join(profile_path, 'inputs') }

  # This tests being able to load complex structures from
  # cli option-specified files.
  [
    'flat',
    'nested',
  ].each do |input_file|
    it "runs OK on #{input_file} inputs" do
      cmd = 'exec '
      cmd += File.join(inputs_profiles_path, 'basic')
      cmd += ' --attrs ' + File.join(inputs_profiles_path, 'basic', 'files', "#{input_file}.yaml")
      cmd += ' --controls ' + input_file
      result = run_inspec_process(cmd)
      result.stderr.must_equal ''
      result.exit_status.must_equal 0
    end
  end

  describe 'when accessing inputs in a variety of scopes' do
    it "is able to read the inputs" do
      cmd = 'exec '
      cmd += File.join(inputs_profiles_path, 'scoping')
      result = run_inspec_process(cmd, json: true)
      result.must_have_all_controls_passing
    end
  end

  describe 'run profile with metadata inputs' do
    it "does not error when inputs are empty" do
      cmd = 'exec '
      cmd += File.join(inputs_profiles_path, 'metadata-empty')
      result = run_inspec_process(cmd, json: true)
      result.stderr.must_include 'WARN: Inputs must be defined as an Array. Skipping current definition.'
      result.exit_status.must_equal 0
    end

    it "errors with invalid input types" do
      cmd = 'exec '
      cmd += File.join(inputs_profiles_path, 'metadata-invalid')
      result = run_inspec_process(cmd, json: true)
      result.stderr.must_equal "Type 'Color' is not a valid input type.\n"
      result.exit_status.must_equal 1
    end

    it "errors with required input not defined" do
      cmd = 'exec '
      cmd += File.join(inputs_profiles_path, 'metadata-required')
      result = run_inspec_process(cmd, json: true)
      result.stderr.must_include "Input 'a_required_input' is required and does not have a value.\n"
      result.exit_status.must_equal 1
    end

    describe 'when profile inheritance is used' do
      it 'should correctly assign input values using namespacing' do
        cmd = 'exec ' + File.join(inputs_profiles_path, 'inheritance', 'wrapper')
        result = run_inspec_process(cmd, json: true)
        result.must_have_all_controls_passing
      end
    end


  #   # TODO - add test for backwards compatibility using 'attribute' in DSL
  end
end