package Transactions
{
   import flash.events.Event;
   
   public class TNeighborPlumbingSeenFriend extends TFarmTransaction
   {
      
      private var m_friendUid:String = "";
      
      private var m_shouldAddToPending:Boolean = false;
      
      private var m_bundleId:String = "";
      
      public function TNeighborPlumbingSeenFriend(friendUid:String, shouldAddToPending:Boolean, bundleId:String)
      {
         super();
         this.m_friendUid = friendUid;
         this.m_shouldAddToPending = shouldAddToPending;
         this.m_bundleId = bundleId;
      }
      
      override public function perform() : void
      {
         signedCall("NeighborPlumbingService.seenFriend",this.m_friendUid,this.m_shouldAddToPending);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var bundleId:String = null;
         var params:Object = null;
         var targetIds:Array = null;
         var iconUrl:String = null;
         if(Boolean(result) && Boolean(result.addNeighborUrl))
         {
            bundleId = this.m_bundleId;
            params = new Object();
            targetIds = new Array();
            iconUrl = Global.getAssetURL("assets/newsfeed/socialPlumbingFeedIcon.png");
            targetIds.push(this.m_friendUid);
            params.uid = Global.player.snUser.uid.toString();
            params.addNeighborUrl = result.addNeighborUrl;
            params.images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}"
            }];
            params.fallbackAction = "NeighborPlumbingAddW2W";
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,targetIds,false);
            dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            dispatchEvent(new Event(Event.CLOSE));
         }
      }
   }
}

