import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/TweetController.dart';
import '../../widgets/tweet_card.dart';
import '../login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityTab extends StatelessWidget{
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context){

    final tweetcontroller = Get.find<TweetController>();
    final Color backgroundColor = const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white, // 앱바를 흰색으로 깔끔하게
        elevation: 0, // 그림자 제거
        scrolledUnderElevation: 0, // 스크롤 시 색상 변경 방지
        centerTitle: false, // 타이틀 왼쪽 정렬
        title: Text(
          'withmovie',
          style: GoogleFonts.dancingScript(
            color: const Color(0XFF4E73DF),
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87), // 아이콘 색상 통일
            onPressed: () {
              Get.toNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Get.offAllNamed('/');
            },
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   mini: true,
      //   onPressed: (){
      //     Get.toNamed('/compose');
      //   },
      //   child: const Icon(Icons.edit),
      //   backgroundColor: const Color.fromARGB(255, 46, 80, 183),
      // ),

      body: Obx(() {
        if (tweetcontroller.isLoading.value){
          return const Center(child: CircularProgressIndicator());
        }

        if(tweetcontroller.tweets.isEmpty){
          return const Center(child: Text('아직 트윗이 없습니다'));
        }

        return RefreshIndicator(
          onRefresh: () => tweetcontroller.loadTimeline(), 
          child: ListView.separated(
            itemCount: tweetcontroller.tweets.length,
            separatorBuilder: (_, __) => const Divider(height: 1,),
            itemBuilder: (context, index){
              final tweet = tweetcontroller.tweets[index];
              return TweetCard(
                tweet: tweet,
                onLike: () => tweetcontroller.toggleLike(tweet.id),
                onDelete: () => tweetcontroller.deleteTweet(tweet.id),
              ); 
            },
          ),
        );
      }),
    );
  }
}
