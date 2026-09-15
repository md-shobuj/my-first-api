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

    // এটাই একটা প্রকৃত টেস্ট কেস, নামটা মানুষের পড়ার জন্য বিবরণ
    test('responds with 405 when method is not POST', () async {

      // নকল context আর নকল request-এর object তৈরি করছি (এখনো এদের কোনো "আচরণ" সেট করা হয়নি)
      final context = _MockRequestContext();
      final request = _MockRequest();

      // "যখন context.request জিজ্ঞেস করা হবে, তখন আমাদের বানানো নকল request-টা দাও"
      when(() => context.request).thenReturn(request);

      // "যখন request.method জিজ্ঞেস করা হবে, তখন HttpMethod.get দাও" (মানে ভান করছি এটা GET request)
      when(() => request.method).thenReturn(HttpMethod.get);

      // এখন আসল login.dart-এর আসল onRequest ফাংশনটা কল করছি, কিন্তু আমাদের নকল context দিয়ে
      final response = await route.onRequest(context);

      // যাচাই করছি — আসল কোড কি সত্যিই 405 status code রিটার্ন করলো?
      // (করার কথা, কারণ login শুধু POST accept করে, GET না)
      expect(response.statusCode, equals(405));
    });
    

    
  });
}