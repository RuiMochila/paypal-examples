class MerchantsController < ApplicationController

  def set_checkout
    value = params[:value]


    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @set_express_checkout = @api.build_set_express_checkout({
      :SetExpressCheckoutRequestDetails => {
        #:ReturnURL => "https://paypal-sdk-samples.herokuapp.com/merchant/do_express_checkout_payment",
        :ReturnURL => "http://localhost:3000",
        :CancelURL => "https://paypal-sdk-samples.herokuapp.com/merchant/set_express_checkout",
        
        :PaymentDetails => [{
          
          :OrderTotal => {
            :currencyID => "EUR",
            :value => value },
          
          :ItemTotal => {
            :currencyID => "EUR",
            :value => value },
          
          :ShippingTotal => {
            :currencyID => "EUR",
            :value => "0.0" },
          
          :TaxTotal => {
            :currencyID => "EUR",
            :value => "0" },

          :NotifyURL => "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify",
          #:ShipToAddress => {
          #  :Name => "Name",
          #  :Street1 => "Street1",
          #  :Street2 => "Street2",
          #  :CityName => "City",
          #  :StateOrProvince => "State",
          #  :Country => "PT",
          #  :PostalCode => "Postal" },
          #:ShippingMethod => "UPSGround",
          
          :PaymentDetailsItem => [{
              :Name => "Tee someting", #Item Name
              :Quantity => 1,
          
              :Amount => {
                :currencyID => "EUR",
                :value => value },
                :ItemCategory => "Physical" }  #Physical, Digital
                                  ], 
          
          :PaymentAction => "Authorization" }] } }) #None, Sale, Order.

    # Make API call & get response
    @set_express_checkout_response = @api.set_express_checkout(@set_express_checkout)
    puts "RESPONSE #{@set_express_checkout_response}"

    # Access Response
    if @set_express_checkout_response.Ack=="Success"
      puts "SUCCESS"
      puts "#{@set_express_checkout_response.Token}" #guardar token
      redirect_to "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=#{@set_express_checkout_response.Token}"
    else
      puts "FAILURE"
      puts "#{@set_express_checkout_response.Errors}"
      redirect_to root_path
    end
    #RESPONSE
    #SUCCESS
    #{
    #  :Timestamp => "2013-05-23T15:54:56+00:00",
    #  :Ack => "Success",
    #  :CorrelationID => "c45a268e1e9d0",
    #  :Version => "98.0",
    #  :Build => "6020375",
    #  :Token => "EC-3VY30968MJ5367308" }

    #FAILURE
    #{
    #  :Timestamp => "2013-05-23T15:59:47+00:00",
    #  :Ack => "Failure",
    #  :CorrelationID => "b05f39d8a592",
    #  :Errors => [{
    #    :ShortMessage => "Invalid Data",
    #    :LongMessage => "This transaction cannot be processed. The amount to be charged is zero.",
    #    :ErrorCode => "10525",
    #    :SeverityCode => "Error" }],
    #  :Version => "98.0",
    #  :Build => "6020375" }

  end


  def get_checkout
    #by token
    token = params[:token]

    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @get_express_checkout_details = @api.build_get_express_checkout_details({
      :Token => token })

    # Make API call & get response
    @get_express_checkout_details_response = @api.get_express_checkout_details(@get_express_checkout_details)

    # Access Response
    if @get_express_checkout_details_response.Ack=="Success"
      puts "SUCCESS"
      puts "PayerID #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerID}"
      #puts "CheckoutDetails #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails}"
      #puts "PaymentDetails #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails}"
      puts "CheckoutStatus #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.CheckoutStatus}"
      puts "Response INSPECT  #{@get_express_checkout_details_response.inspect}"
      redirect_to root_path
    else
      puts "FAILURE"
      puts "#{@get_express_checkout_details_response.Errors}"
      #puts "#{@get_express_checkout_details_response.Errors.LongMessage}"
      redirect_to root_path
    end
    #  {
    #:Timestamp => "2013-05-23T16:38:04+00:00",
    #:Ack => "Success",
    #:CorrelationID => "2f9af84186ba9",
    #:Version => "98.0",
    #:Build => "6020375",
    #:GetExpressCheckoutDetailsResponseDetails => {
    #  :Token => "EC-71K38552PJ0578531",
    #  :PayerInfo => {
    #    :Payer => "rui.mochila-test.sender2@gmail.com",
    #    :PayerID => "KGYEJ9Z9FHT74",
    #    :PayerStatus => "verified",
    #    :PayerName => {
    #      :FirstName => "Rui",
    #      :LastName => "Mochila" },
    #    :PayerCountry => "US",
    #    :Address => {
    #      :Name => "John Doe",
    #      :Street1 => "1 Main St",
    #      :CityName => "San Jose",
    #      :StateOrProvince => "CA",
    #      :Country => "US",
    #      :CountryName => "United States",
    #      :PostalCode => "95131",
    #      :AddressOwner => "PayPal",
    #      :AddressStatus => "Confirmed" } },
    #  :CheckoutStatus => "PaymentActionNotInitiated",
    #  :PaymentDetails => [{
    #    :OrderTotal => {
    #      :currencyID => "EUR",
    #      :value => "20.00" },
    #    :ItemTotal => {
    #      :currencyID => "EUR",
    #      :value => "20.00" },
    #    :ShippingTotal => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :HandlingTotal => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :TaxTotal => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :NotifyURL => "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify",
    #    :ShipToAddress => {
    #      :Name => "John Doe",
    #      :Street1 => "1 Main St",
    #      :CityName => "San Jose",
    #      :StateOrProvince => "CA",
    #      :Country => "US",
    #      :CountryName => "United States",
    #      :PostalCode => "95131",
    #      :AddressOwner => "PayPal",
    #      :AddressStatus => "Confirmed",
    #      :AddressNormalizationStatus => "None" },
    #    :PaymentDetailsItem => [{
    #      :Name => "Tee shirt",
    #      :Quantity => 1,
    #      :Tax => {
    #        :currencyID => "EUR",
    #        :value => "0.00" },
    #      :Amount => {
    #        :currencyID => "EUR",
    #        :value => "20.00" },
    #      :ItemCategory => "Physical" }],
    #    :InsuranceTotal => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :ShippingDiscount => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :InsuranceOptionOffered => "false" }] } }


#{
#  :Timestamp => "2013-05-23T18:25:09+00:00",
#  :Ack => "Failure",
#  :CorrelationID => "73b7504ad3e9a",
#  :Errors => [{
#    :ShortMessage => "Invalid token",
#    :LongMessage => "Invalid token.",
#    :ErrorCode => "10410",
#    :SeverityCode => "Error" }],
#  :Version => "98.0",
#  :Build => "6020375",
#  :GetExpressCheckoutDetailsResponseDetails => {
#    :PayerInfo => {
#      :PayerStatus => "unverified",
#      :Address => {
#        :AddressOwner => "PayPal",
#        :AddressStatus => "None" } },
#    :PaymentDetails => [{
#      :ShipToAddress => {
#        :AddressOwner => "PayPal",
#        :AddressStatus => "None",
#        :AddressNormalizationStatus => "None" } }] } }

  end



  def do_checkout
    #passo nos params ou um Authorization ou Sale
    #ou para n confundir por agora... duplico?
    token = params[:token]
    payerID = params[:payerID]
    value = params[:value]

    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @do_express_checkout_payment = @api.build_do_express_checkout_payment({
      :DoExpressCheckoutPaymentRequestDetails => {
        :PaymentAction => "Authorization", #Ou Sale
        :Token => token,
        :PayerID => payerID,
        :PaymentDetails => [{
          :OrderTotal => {
            :currencyID => "EUR",
            :value => value },
          :NotifyURL => "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify" }] } })

    # Make API call & get response
    @do_express_checkout_payment_response = @api.do_express_checkout_payment(@do_express_checkout_payment)

    # Access Response
    if @do_express_checkout_payment_response.Ack=="Success"
      puts "SUCCESS"
      puts "PaymentInfo #{@do_express_checkout_payment_response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo}"
      #THE WALK OF SHAME!! THE WALK OF SHAME!! THE WALK OF SHAME!! THE WALK OF SHAME!!
      #Não consigo aceder de maneira nenhuma, API muito fraquinha.
      puts "TransactionID #{@do_express_checkout_payment_response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo.inspect[79..95]}"
      redirect_to root_path
      #@do_express_checkout_payment_response.FMFDetails
    else
      puts "FAILURE"
      puts "ERRORS #{@do_express_checkout_payment_response.Errors}"
      redirect_to root_path
    end

    #  {
    #:Timestamp => "2013-05-23T16:38:48+00:00",
    #:Ack => "Success",
    #:CorrelationID => "41a28f7f975f5",
    #:Version => "98.0",
    #:Build => "6020375",
    #:DoExpressCheckoutPaymentResponseDetails => {
    #  :Token => "EC-71K38552PJ0578531",
    #  :PaymentInfo => [{
    #    :TransactionID => "0TB99172F4263964N",
    #    :TransactionType => "express-checkout",
    #    :PaymentType => "instant",
    #    :PaymentDate => "2013-05-23T16:38:48+00:00",
    #    :GrossAmount => {
    #      :currencyID => "EUR",
    #      :value => "20.00" },
    #    :TaxAmount => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :PaymentStatus => "Pending",
    #    :PendingReason => "authorization",
    #    :ReasonCode => "none",
    #    :ProtectionEligibility => "Eligible",
    #    :ProtectionEligibilityType => "ItemNotReceivedEligible,UnauthorizedPaymentEligible",
    #    :SellerDetails => {
    #      :SecureMerchantAccountID => "TWLK53YN7GDM6" } }],
    #  :SuccessPageRedirectRequested => "false" } }


  end

  def do_capture
    transactionID = params[:transactionID]
    value = params[:value]

    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @do_capture = @api.build_do_capture({
      :AuthorizationID => transactionID,
      :Amount => {
        :currencyID => "EUR",
        :value => value },
      :CompleteType => "Complete" })

    # Make API call & get response
    @do_capture_response = @api.do_capture(@do_capture)

    # Access Response
    if @do_capture_response.Ack=="Success"
      puts "SUCCESS"
      puts "RESPONSE DETAILS #{@do_capture_response.DoCaptureResponseDetails}"
      redirect_to root_path
    else
      puts "FAILURE"
      puts "ERRORS #{@do_capture_response.Errors}"
      redirect_to root_path
    end


    #  {
    #:Timestamp => "2013-05-23T17:26:39+00:00",
    #:Ack => "Success",
    #:CorrelationID => "4d7fefc38b140",
    #:Version => "98.0",
    #:Build => "6020375",
    #:DoCaptureResponseDetails => {
    #  :AuthorizationID => "6J405897PX2987138",
    #  :PaymentInfo => {
    #    :TransactionID => "9UV8297049342771B",
    #    :ParentTransactionID => "6J405897PX2987138",
    #    :TransactionType => "express-checkout",
    #    :PaymentType => "instant",
    #    :PaymentDate => "2013-05-23T17:26:38+00:00",
    #    :GrossAmount => {
    #      :currencyID => "EUR",
    #      :value => "50.00" },
    #    :FeeAmount => {
    #      :currencyID => "EUR",
    #      :value => "1.80" },
    #    :SettleAmount => {
    #      :currencyID => "EUR",
    #      :value => "76.77" },
    #    :TaxAmount => {
    #      :currencyID => "EUR",
    #      :value => "0.00" },
    #    :ExchangeRate => "1.59273",
    #    :PaymentStatus => "Completed",
    #    :PendingReason => "none",
    #    :ReasonCode => "none",
    #    :ProtectionEligibility => "Eligible",
    #    :ProtectionEligibilityType => "ItemNotReceivedEligible,UnauthorizedPaymentEligible" } } }

  end

  def do_void
    transactionID = params[:transactionID]

    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @do_void = @api.build_do_void({
      :AuthorizationID => transactionID })

    # Make API call & get response
    @do_void_response = @api.do_void(@do_void)

    # Access Response
    if @do_void_response.Ack=="Success"
      puts "SUCCESS"
      puts "AUTH ID #{@do_void_response.AuthorizationID}"
      #@do_void_response.MsgSubID
      redirect_to root_path
    else
      puts "FAILURE"
      puts "ERRORS #{@do_void_response.Errors}"
      redirect_to root_path
    end

    #  {
    #:Timestamp => "2013-05-23T16:40:42+00:00",
    #:Ack => "Success",
    #:CorrelationID => "25aa9650769c2",
    #:Version => "98.0",
    #:Build => "6020375",
    #:AuthorizationID => "0TB99172F4263964N" }
        
  end  


end
