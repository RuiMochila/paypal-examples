class AdaptivesController < ApplicationController

  #a partir do mínimo atingido de campanha pode começar a receber o pagamento automáticamente.

  def create

    #require 'paypal-sdk-adaptivepayments'
    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @preapproval = @api.build_preapproval({
      :cancelUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/preapproval",
      :currencyCode => "EUR",
      #:feesPayer => "SENDER",
      #:endingDate => "2013-06-30T00:00:00+00:00",
      #:maxAmountPerPayment => 40.0,
      :maxTotalAmountOfAllPayments => 40.0,
      :maxNumberOfPayments => 1,
      :returnUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/preapproval",
      :ipnNotificationUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/ipn_notify",
      #:senderEmail => "rui.mochila-test.sender2@gmail.com", #"Platform.sdk.seller@gmail.com",
      :startingDate =>  Time.now }) #{}"2013-05-21T09:47:38-07:00"

    # Make API call & get response
    @preapproval_response = @api.preapproval(@preapproval)
    puts "THERE! ITS A #{@preapproval_response.error}"

    # Access Response
    if @preapproval_response.responseEnvelope.ack=="Success"
      preapprovalKey = @preapproval_response.preapprovalKey
      redirect_to "https://www.sandbox.paypal.com/webscr?cmd=_ap-preapproval&preapprovalkey=#{preapprovalKey}"
    else
      @preapproval_response.error
      flash[:notice]="deu merda"
      redirect_to root_path
    end
  
  end

  def preapproval_details
    preapprovalKey = params[:preapprovalKey]

    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @preapproval_details = @api.build_preapproval_details({
      :preapprovalKey => preapprovalKey })

    # Make API call & get response
    @preapproval_details_response = @api.preapproval_details(@preapproval_details)

    # Access Response
    if @preapproval_details_response.responseEnvelope.ack=="Success"
      puts "Success"
      puts "APPROVED #{@preapproval_details_response.approved}"
      puts "CANCELURL #{@preapproval_details_response.cancelUrl}"
      puts "CUR PAYMENTS #{@preapproval_details_response.curPayments}"
      puts "CUR PAYMENTS AMOUNT #{@preapproval_details_response.curPaymentsAmount}"
      puts "CUR PERIOD ATTEMPTS #{@preapproval_details_response.curPeriodAttempts}"
      puts "CUR PERIOD ENDING #{@preapproval_details_response.curPeriodEndingDate}"
      puts "CURRENCY CODE #{@preapproval_details_response.currencyCode}"
      puts "DATE MONTH #{@preapproval_details_response.dateOfMonth}"
      puts "DAY WEEK #{@preapproval_details_response.dayOfWeek}"
      puts "ENDING DATE #{@preapproval_details_response.endingDate}"
      puts "MAX AMOUNT PER PAYMENT #{@preapproval_details_response.maxAmountPerPayment}"
      puts "MAX NUMBER OF PAYMENTS #{@preapproval_details_response.maxNumberOfPayments}"
      puts "MAX NUMBER PER PERIOD #{@preapproval_details_response.maxNumberOfPaymentsPerPeriod}"
      puts " #{@preapproval_details_response.maxTotalAmountOfAllPayments}"
      puts " #{@preapproval_details_response.paymentPeriod}"
      puts "PIN TYPE #{@preapproval_details_response.pinType}"
      puts " #{@preapproval_details_response.returnUrl}"
      puts "SENDER EMAIL #{@preapproval_details_response.senderEmail}"
      puts " #{@preapproval_details_response.memo}"
      puts " #{@preapproval_details_response.startingDate}"
      puts "STATUS #{@preapproval_details_response.status}"
      puts " #{@preapproval_details_response.ipnNotificationUrl}"
      puts " #{@preapproval_details_response.addressList}"
      puts "FEES PAYER #{@preapproval_details_response.feesPayer}"
      puts " #{@preapproval_details_response.displayMaxTotalAmount}"
      puts "SENDER #{@preapproval_details_response.sender}"
      redirect_to root_path
    else
      puts "Failure"
      puts " #{@preapproval_details_response.error}"
      redirect_to root_path
    end
  end

  def confirm
    preapprovalKey = params[:preapprovalKey]
    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @confirm_preapproval = @api.build_confirm_preapproval({
      :preapprovalKey => preapprovalKey })

    # Make API call & get response
    @confirm_preapproval_response = @api.confirm_preapproval(@confirm_preapproval)

    # Access Response
    if @confirm_preapproval_response.responseEnvelope.ack=="Success"
      puts "SUCCESS"
      redirect_to root_path
    else
      puts "FAILURE"
      puts "ERROR #{@confirm_preapproval_response.error}"
      redirect_to root_path
    end
  end

  #por alguma razão tem dado status CREATED em vez de COMPLETED, insinuando que falta aprovação
  #apesar de referir a preapprovalKey
  def pay
    
    preapprovalKey = params[:preapprovalkey]
    receiver = params[:receiver]

    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @pay = @api.build_pay({
      :actionType => "PAY",
      :cancelUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/pay",
      :currencyCode => "EUR",
      #:feesPayer => "SENDER",
      :ipnNotificationUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/ipn_notify",
      :preapprovalKey => preapprovalKey,
      :receiverList => {
        :receiver => [{
          :amount => 40.0,
          :email => receiver }] },
      :returnUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/pay",
      :fundingConstraint => {
        :allowedFundingType => {
          :fundingTypeInfo => [{
            :fundingType => "BALANCE" }] } } })

    # Make API call & get response
    @pay_response = @api.pay(@pay)
    puts "PAY RESPONSE #{@pay_response}"
    # Access Response. N devo ter tanto de reposta neste caso...
    if @pay_response.responseEnvelope.ack=="Success"
      puts "SUCCESS"
      puts "PAY KEY #{@pay_response.payKey}"
      puts "EXEC STATUS #{@pay_response.paymentExecStatus}"
      puts "ERROR LIST #{@pay_response.payErrorList}"
      #puts "INFO LIST #{@pay_response.paymentInfoList}"
      #puts "SENDER #{@pay_response.sender}"
      #puts "FUNDING PLAN #{@pay_response.defaultFundingPlan}"
      #puts "DATA LIST #{@pay_response.warningDataList}"

      #guardar infos relacionadas com o a transação.

      flash[:notice] = "Success"
      redirect_to root_path
    else
      puts "ITS AN ERROR #{@pay_response.error}"
      flash[:notice] = "Failure"
      redirect_to root_path
    end
  end


  def payment_details
    preapprovalKey = params[:preapprovalkey]
    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @payment_details = @api.build_payment_details({
      :payKey => preapprovalKey })

    # Make API call & get response
    @payment_details_response = @api.payment_details(@payment_details)

    # Access Response
    if @payment_details_response.responseEnvelope.ack=="Success"
      puts "SUCCESS"
      puts " #{@payment_details_response.cancelUrl}"
      puts " #{@payment_details_response.currencyCode}"
      puts " #{@payment_details_response.ipnNotificationUrl}"
      puts " #{@payment_details_response.memo}"
      puts " #{@payment_details_response.paymentInfoList}"
      puts " #{@payment_details_response.returnUrl}"
      puts " #{@payment_details_response.senderEmail}"
      puts " #{@payment_details_response.status}"
      puts " #{@payment_details_response.trackingId}"
      puts " #{@payment_details_response.payKey}"
      puts " #{@payment_details_response.actionType}"
      puts " #{@payment_details_response.feesPayer}"
      puts " #{@payment_details_response.reverseAllParallelPaymentsOnError}"
      puts " #{@payment_details_response.preapprovalKey}"
      puts " #{@payment_details_response.fundingConstraint}"
      puts " #{@payment_details_response.sender}"
      redirect_to root_path
    else
      puts "FAILURE"
      puts "ERROR: #{@payment_details_response.error}"
      redirect_to root_path
    end
  end


  def cancel
    preapprovalKey = params[:preapprovalKey]
    @api = PayPal::SDK::AdaptivePayments::API.new

    # Build request object
    @cancel_preapproval = @api.build_cancel_preapproval({
      :preapprovalKey => preapprovalKey })
    puts "CANCEL PREAPPROVAL #{@cancel_preapproval}"

    # Make API call & get response
    @cancel_preapproval_response = @api.cancel_preapproval(@cancel_preapproval)
    puts "CANCEL PREAPPROVAL RESPONSE #{@cancel_preapproval_response}"
    # Access Response
    if @cancel_preapproval_response.responseEnvelope.ack=="Success"
      puts "SUCCESS"
      flash[:notice] = "Success"
      redirect_to root_path 
    else
      @cancel_preapproval_response.error
      puts "FAILURE #{@cancel_preapproval_response.error}"
      flash[:notice] = "Failure"
      redirect_to root_path 
    end
  end

end

  