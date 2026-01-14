import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minix_flutter/controllers/TweetController.dart';
import '../../widgets/tweet_card.dart';
import '../login_screen.dart';

class CommunityTab extends StatelessWidget{
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context){

    final tweetcontroller = Get.find<TweetController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        title: const Text('영화랑'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: (){
              Get.toNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: (){
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
