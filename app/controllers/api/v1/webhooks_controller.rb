# encoding: utf-8
module Api::V1
  class WebhooksController < AppController
    before_filter :check_webhooks
    KeyValues::Webhook::Event.all.each do |event| # '订单发货'事件回调要求应用拥有'获取订单'的权限
      doorkeeper_for :create, scopes: event.scopes, if: lambda { !@api_client and params[:webhook][:event] == event.code }
    end

    def create
      @webhook = shop.webhooks.build params[:webhook]
      @webhook.application = doorkeeper_token.application
      @webhook.save!
    end

    private
    def check_webhooks
      if !params[:webhook] or !KeyValues::Webhook::Event.all.map(&:code).include?(params[:webhook][:event])
        render json: { errors: {} } and return
      end
    end

  end
end
