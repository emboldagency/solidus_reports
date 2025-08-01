# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::ReportsController do
  stub_authorization!

  after do
    described_class.available_reports.delete_if do |key, _value|
      key != :sales_total
    end
  end

  describe "ReportsController.available_reports" do
    it "contains sales_total" do
      expect(described_class.available_reports.key?(:sales_total)).to be true
    end
  end

  describe "ReportsController.add_available_report!" do
    context "when adding the report name" do
      it "contains the report" do
        described_class.add_available_report!(:some_report)
        expect(described_class.available_reports.key?(:some_report)).to be true
        expect(described_class.available_reports[:some_report]).to eq(
          name: :some_report,
          description: "some_report_description"
        )
      end
    end
  end

  describe "GET sales_total" do
    subject { get :sales_total, params: params }

    let!(:order_complete_start_of_month) { create(:completed_order_with_totals) }
    let!(:order_complete_mid_month) { create(:completed_order_with_totals) }
    let!(:order_non_complete) { create(:order, completed_at: nil) }

    before do
      # can't set completed_at during factory creation
      order_complete_start_of_month.completed_at = Time.current.beginning_of_month + 1.minute
      order_complete_start_of_month.save!

      order_complete_mid_month.completed_at = Time.current.beginning_of_month + 15.days
      order_complete_mid_month.save!
    end

    shared_examples "sales total report" do
      it "responds with success" do
        expect(response).to be_successful
      end

      it "sets search to be a ransack search" do
        subject
        expect(assigns(:search)).to be_a Ransack::Search
      end

      it "sets orders correctly for date parameters" do
        subject
        expect(assigns(:orders)).to eq expected_returned_orders
      end

      it "does not include non-complete orders" do
        subject
        expect(assigns(:orders)).not_to include(order_non_complete)
      end

      it "correctlies set the totals hash" do
        subject
        expect(assigns(:totals)).to eq expected_totals
      end
    end

    context "when no dates are specified" do
      let(:params) { {} }

      it_behaves_like "sales total report" do
        let(:expected_returned_orders) { [order_complete_mid_month, order_complete_start_of_month] }
        let(:expected_totals) {
          {
            "USD" => {
              item_total: Money.new(2000, "USD"),
              adjustment_total: Money.new(0, "USD"),
              sales_total: Money.new(22_000, "USD")
            }
          }
        }
      end
    end

    context "when params has a completed_at_gt" do
      let(:params) { {q: {completed_at_gt: Time.current.beginning_of_month + 1.day}} }

      it_behaves_like "sales total report" do
        let(:expected_returned_orders) { [order_complete_mid_month] }
        let(:expected_totals) {
          {
            "USD" => {
              item_total: Money.new(1000, "USD"),
              adjustment_total: Money.new(0, "USD"),
              sales_total: Money.new(11_000, "USD")
            }
          }
        }
      end
    end

    context "when params has a compeleted_at_lt" do
      let(:params) { {q: {completed_at_lt: Time.current.beginning_of_month}} }

      it_behaves_like "sales total report" do
        let(:expected_returned_orders) { [order_complete_start_of_month] }
        let(:expected_totals) {
          {
            "USD" => {
              item_total: Money.new(1000, "USD"),
              adjustment_total: Money.new(0, "USD"),
              sales_total: Money.new(11_000, "USD")
            }
          }
        }
      end
    end
  end

  describe "GET index" do
    it "is ok" do
      get :index
      expect(response).to be_ok
    end
  end
end
