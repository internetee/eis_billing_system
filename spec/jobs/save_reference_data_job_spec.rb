require 'rails_helper'

RSpec.describe SaveReferenceDataJob, type: :job do
  it 'creates new references and skips duplicates' do
    ActiveJob::Base.queue_adapter = :test
    response = [
      { 'reference_number' => 'R-1', 'initiator' => 'registry', 'registrar_name' => 'ACME' },
      { 'reference_number' => 'R-1', 'initiator' => 'registry', 'registrar_name' => 'ACME' }
    ]

    added, skipped = described_class.perform_now(response)

    expect(added).to eq(1)
    expect(skipped).to eq(1)
    expect(Reference.find_by(reference_number: 'R-1')).to be_present
  end
end


