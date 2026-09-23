import 'package:dart_frog/dart_frog.dart'; // RequestContext, Request, HttpMethod পাওয়ার জন্য
import 'package:mocktail/mocktail.dart'; // Mock, when(), thenReturn() পাওয়ার জন্য
import 'package:test/test.dart'; // group(), test(), expect() পাওয়ার জন্য

import '../../routes/login.dart' as route;
// আসল login.dart ফাইলটা import করছি, যেটা টেস্ট করব
// "as route" দিয়ে একটা ছোট নাম (alias) দিলাম, যাতে route.onRequest() লিখে বোঝা যায় কোন ফাইলের ফাংশন

// আসল RequestContext-এর "নকল" সংস্করণ বানাচ্ছি — এটা RequestContext-এর মতোই আচরণ করবে, কিন্তু ভুয়া
class _MockRequestContext extends Mock implements RequestContext {}

// একইভাবে আসল Request-এরও একটা নকল সংস্করণ বানাচ্ছি
class _MockRequest extends Mock implements Request {}

void main() {
  // সম্পর্কিত সব টেস্ট একসাথে "GET/PUT etc. /login" নামের গ্রুপে রাখছি (শুধু organizing-এর জন্য)
  group('GET/PUT etc. /login', () {


    test('responds with 405 when method is not POST', () async {

  
      final context = _MockRequestContext();
      final request = _MockRequest();

      when(() => context.request).thenReturn(request);

  
      when(() => request.method).thenReturn(HttpMethod.get);

     
      final response = await route.onRequest(context);


      expect(response.statusCode, equals(405));
    });
    

    
  });
}