import 'package:flutter/material.dart';
import 'package:flutter_with_stripe/environment/stripe_vars.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class StripePaymentScreen2 extends StatefulWidget {
  @override
  _StripePaymentScreen2State createState() => _StripePaymentScreen2State();
}

class _StripePaymentScreen2State extends State<StripePaymentScreen2> {

  var apiUrl = 'https://26d7af67848f.ngrok.io';
  TextEditingController _amountTextController;
  TextEditingController _paymentDefinitionTextController;
  bool _isLoading = false;


  @override
  initState() {
    super.initState();
    StripePayment.setOptions(
      StripeOptions(        
        publishableKey: stripePublishableKey, //YOUR_PUBLISHABLE_KEY
        // merchantId: "Test",  //YOUR_MERCHANT_ID
        // androidPayMode: 'test'
      )
    );
    _amountTextController = TextEditingController(
        text: '1'
    );
    _paymentDefinitionTextController = TextEditingController(
        text: ''
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay with Card Form'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (ctx) => Stack(
          children: [

            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus( new FocusNode() );
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          // width: 120,
                          child: TextField(
                            controller: _paymentDefinitionTextController,
                            // keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: ( val ) {
                              // _amountTextController.text = val;
                              setState(() { });
                              print('val -> ' + val.toString());
                            },
                            decoration: InputDecoration(
                              labelText: 'Payment Definition'
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          child: TextField(
                            controller: _amountTextController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: ( val ) {
                              // _amountTextController.text = val;
                              setState(() { });
                              print('val -> ' + val.toString());
                            },
                            decoration: InputDecoration(
                              labelText: 'Amount'
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      RaisedButton(
                        child: Text(
                          'Pay with Credit Card',
                          style: TextStyle(
                            color: Colors.white
                          ),                  
                        ),
                        color: Colors.red,
                        onPressed: () async {
                          FocusScope.of(context).requestFocus( new FocusNode() );
                          setState(() {
                            _isLoading = true;
                          });

                          var paymentMethod = await StripePayment.paymentRequestWithCardForm(
                            CardFormPaymentRequest(),

                          );
                          
                          print(paymentMethod);

                          var res = await http.post(
                            apiUrl + '/api/payment',
                            headers: {
                              'Content-Type': 'application/json'
                            },
                            body: convert.jsonEncode(
                              {
                                'paymentMethodId': paymentMethod.id,
                                'description': _paymentDefinitionTextController.text,
                                'amount': double.tryParse(_amountTextController.text) == null 
                                  ? 1 * 100 
                                  : double.parse(_amountTextController.text) * 100, 
                              }
                            )
                          );
                          print(res);
                          setState(() {
                            _isLoading = false;
                          });
                          if (res.statusCode == 200 ) {
                            var extractedData = convert.jsonDecode(res.body);
                            var extractedAmount = double.parse(extractedData['amount'].toString() ) / 100;
                            var extractedDefinition = extractedData['definition'];
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Successfully paid an amount of'
                                  + ' ${extractedAmount.toStringAsFixed(2)} with Defitinion: $extractedDefinition'
                                ),
                                duration: Duration(milliseconds: 4500),
                              ),

                            );
                          }
                          if (res.statusCode == 500 ) {
                            Scaffold.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res.body,
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                                duration: Duration(milliseconds: 4500),
                                backgroundColor: Colors.red,
                              ),

                            );
                          }                          
                        },
                      ) 
                    ],
                  ),
                ),
              ),
            ),
            if ( _isLoading ) Opacity(
              opacity: 0.5,
              child: Container(
                height: double.infinity,
                color: Colors.grey,     
              ),
            ),
            if ( _isLoading ) Container(
              height: double.infinity,              
              child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      // https://stackoverflow.com/questions/49952048/how-to-change-color-of-circularprogressindicator
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 6,                      
                    ),
                    SizedBox(height: 12),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Please wait...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black
                          
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
              )
            ),
          ],
        )
        
      ),
      
    );
  }
}