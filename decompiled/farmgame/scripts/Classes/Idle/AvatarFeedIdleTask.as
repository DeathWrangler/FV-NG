package Classes.Idle
{
   import Classes.EmbeddedArt;
   import Classes.UGC.UGCAvatarFeedImage;
   import Managers.UserContentManager;
   import flash.external.ExternalInterface;
   
   public class AvatarFeedIdleTask extends BaseIdleTask
   {
      
      private var m_fired:Boolean = false;
      
      public function AvatarFeedIdleTask()
      {
         super();
      }
      
      override public function get canFire() : Boolean
      {
         return Global.player.avatarVisible;
      }
      
      override public function fire() : void
      {
         var ugcAvatar:UGCAvatarFeedImage = null;
         if(!this.m_fired)
         {
            this.m_fired = true;
            ugcAvatar = new UGCAvatarFeedImage(Global.player.avatar,UserContentManager.FEATURE_AVATAR_APPEARANCE,EmbeddedArt.avatarComment);
            UserContentManager.getInstance().createFeedImage(ugcAvatar,this.onAvatarFeedImageGenerated);
            IdleTaskQueue.getInstance().addTask(this);
         }
      }
      
      private function onAvatarFeedImageGenerated(result:Object) : void
      {
         var iconUrl:String = result.imagePath;
         Global.player.feedImage = iconUrl;
         if(Global.worldManager.isVisiting() && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            ExternalInterface.call("sendPromoBarMessage","showComments",[Global.worldManager.getVisiting(),Global.worldManager.getVisitName(true),Global.player.feedImage]);
         }
         else
         {
            ExternalInterface.call("sendPromoBarMessage","showComments",[Global.player.uid,null,Global.player.feedImage]);
         }
      }
   }
}

