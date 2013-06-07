class MerchantsController < ApplicationController

  def set_checkout
    value = params[:value] #o value vai buscar através do preço estipulado na bd, converter formato xx.xx
    #faltam os outros parametros de produto e cliente

    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @set_express_checkout = @api.build_set_express_checkout({
      :SetExpressCheckoutRequestDetails => {
        #:ReturnURL => "https://paypal-sdk-samples.herokuapp.com/merchant/do_express_checkout_payment",
        :ReturnURL => "http://localhost:3000/return",
        :CancelURL => "https://localhost:3000/cancelPayment",
        
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
      transaction = Transaction.new(token: @set_express_checkout_response.Token, value: value, payment_state: 'Initiated', product_id: 1)
      if transaction.save
        puts "Transaction created #{transaction.inspect}"
      end
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


      puts "PayerID #{@get_express_checkout_details_response.
              GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerID}"
      puts ""

      #puts "CheckoutDetails #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails}"
      #puts "PaymentDetails #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails}"
      puts "CheckoutStatus #{@get_express_checkout_details_response.
              GetExpressCheckoutDetailsResponseDetails.CheckoutStatus}"
      # Este status vai ser controlado para saber se está pago ou não. 
      # Logo no set express -> PaymentActionNotInitiated
      # Após o pagamento passa a -> PaymentActionCompleted
      puts ""


      # Cuidado porque este campo n está disponivel antes do do_chekout, perguntar noutro campo
      # Maybe... @CheckoutStatus="PaymentActionCompleted"
      if @get_express_checkout_details_response.
              GetExpressCheckoutDetailsResponseDetails.CheckoutStatus=="PaymentActionCompleted"
        puts "TransactionID #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails.TransactionId}"
        puts ""
      end


      # # puts "Response INSPECT  #{@get_express_checkout_details_response.inspect.split}"
      # "#{@get_express_checkout_details_response.inspect}".split(',').each {|s| puts s}
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

    # APÓS PAGAMENTO
  #   {
  # :Timestamp => "2013-06-05T13:42:55+00:00",
  # :Ack => "Success",
  # :CorrelationID => "e73f7f03848e",
  # :Version => "98.0",
  # :Build => "6202528",
  # :GetExpressCheckoutDetailsResponseDetails => {
  #   :Token => "EC-2NK67790GJ383324H",
  #   :PayerInfo => {
  #     :Payer => "rui.mochila-test.sender2@gmail.com",
  #     :PayerID => "KGYEJ9Z9FHT74",
  #     :PayerStatus => "verified",
  #     :PayerName => {
  #       :FirstName => "Rui",
  #       :LastName => "Mochila" },
  #     :PayerCountry => "US",
  #     :Address => {
  #       :Name => "John Doe",
  #       :Street1 => "1 Main St",
  #       :CityName => "San Jose",
  #       :StateOrProvince => "CA",
  #       :Country => "US",
  #       :CountryName => "United States",
  #       :PostalCode => "95131",
  #       :AddressOwner => "PayPal",
  #       :AddressStatus => "Confirmed" } },
  #   :CheckoutStatus => "PaymentActionCompleted",
  #   :PaymentDetails => [{
  #     :OrderTotal => {
  #       :currencyID => "USD",
  #       :value => "5.00" },
  #     :ShippingTotal => {
  #       :currencyID => "USD",
  #       :value => "0.00" },
  #     :HandlingTotal => {
  #       :currencyID => "USD",
  #       :value => "0.00" },
  #     :TaxTotal => {
  #       :currencyID => "USD",
  #       :value => "0.00" },
  #     :NotifyURL => "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify",
  #     :ShipToAddress => {
  #       :Name => "John Doe",
  #       :Street1 => "1 Main St",
  #       :CityName => "San Jose",
  #       :StateOrProvince => "CA",
  #       :Country => "US",
  #       :CountryName => "United States",
  #       :PostalCode => "95131",
  #       :AddressOwner => "PayPal",
  #       :AddressStatus => "Confirmed",
  #       :AddressNormalizationStatus => "None" },
  #     :InsuranceTotal => {
  #       :currencyID => "USD",
  #       :value => "0.00" },
  #     :ShippingDiscount => {
  #       :currencyID => "USD",
  #       :value => "0.00" },
  #     :InsuranceOptionOffered => "false",
  #     :TransactionId => "05498390PX0375310" }],
  #   :PaymentRequestInfo => [{
  #     :TransactionId => "05498390PX0375310" }] } }


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


  #http://localhost:3000/return?token=EC-68X85466U8198983V&PayerID=KGYEJ9Z9FHT74
  def do_checkout
    
    token = params[:token]
    payerID = params[:PayerID]
    # value = params[:value] #Tem de se ir buscar à BD, comparar o da BD com o no get_checkout

    #Temos um payerID, faz get_checkout e pergunta pelo valor e estado de pagamento
    transaction = Transaction.find_by_token(token)
    value = transaction.value
    puts "Transaction found #{transaction.inspect}"

    @api = PayPal::SDK::Merchant::API.new
    # Build request object
    @get_express_checkout_details = @api.build_get_express_checkout_details({
      :Token => token })

    # Make API call & get response
    @get_express_checkout_details_response = @api.get_express_checkout_details(@get_express_checkout_details)

    if @get_express_checkout_details_response.Ack=="Success"
      puts "SUCCESS"

      if @get_express_checkout_details_response.
        GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerStatus=="verified"

        #puts "TransactionID #{@get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails.TransactionId}"
        
        #Verificar value pago aqui
        #Martela a string
        order = @get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails.inspect
        puts "Order #{order}"

        currency = order[order.index('currency'), 16]
        puts "Currency all #{currency}"
        #puts "Currency #{currency[currency.index('"')+1, 3]}"
        puts "Currency #{currency[currency.index('"')+1, 3]}"
        #puts "#{currency.rindex('"')-1}"

        value = order[order.index('value'), 16]
        puts "Value all #{value}"
        puts "Value #{value[value.index('"')+1, value.index('.')]}"

        if @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PaymentDetails.OrderTotal.currencyID == "EUR" &&
          @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PaymentDetails.OrderTotal.value == value

          transaction.user_email = @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PayerInfo.Payer

          transaction.payer_id = @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerID

          transaction.user_name = @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerName.FirstName + " " + @get_express_checkout_details_response.
          GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerName.LastName

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

            @get_express_checkout_details = @api.build_get_express_checkout_details({
              :Token => token })
            @get_express_checkout_details_response = @api.get_express_checkout_details(@get_express_checkout_details)
            transaction.transaction_id = @get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails.PaymentDetails.TransactionId
            transaction.payment_state = 'Authorized'
            transaction.save

            puts "Transaction Complete: #{transaction.inspect}"
            # ir buscar a campanha referente a esta transaction e fazer render campaign show , passar param?
            redirect_to root_path
            
          else
            puts "ERRORS #{@do_express_checkout_payment_response.Errors}"
            redirect_to root_path
          end

        else
          puts "Nao tinha o mesmo valor e currency Espertinhos"
        end
      else
        puts "O pagamento nao foi concluido"
      end


    else
      puts "FAILURE"
      puts "#{@get_express_checkout_details_response.Errors}"
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

  def cancel
    
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
