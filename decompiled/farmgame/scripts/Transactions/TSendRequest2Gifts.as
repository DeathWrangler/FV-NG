package Transactions
{
   import Widgets.Windows.MFSSendFlashGifts;
   
   public class TSendRequest2Gifts extends TFarmTransaction
   {
      
      public static const SEEN_FLAG_REQS2_RECENTLY_GIFTED:String = "reqs2RecentlyGifted";
      
      public static const REF_RECENTLY_PLAYED_GIFT:String = "recentlyPlayedGift";
      
      public static const HUD_CLICK:String = "HUD_clicked";
      
      public static const HUD_CLICK_MESSAGE_COUNTER:String = "RP_HUD_icon";
      
      private var m_callback:Function;
      
      private var m_giftCode:String;
      
      private var m_requestIds:Array;
      
      private var m_ref:String;
      
      private var m_source:String;
      
      private var m_serverTime:int = 0;
      
      public function TSendRequest2Gifts(giftCode:String, requestIds:Array, ref:String, source:String, serverTime:int = 0, callback:Function = null)
      {
         super();
         this.m_giftCode = giftCode;
         this.m_requestIds = requestIds;
         this.m_ref = ref;
         this.m_callback = callback;
         this.m_serverTime = serverTime;
         if(source == HUD_CLICK)
         {
            this.m_source = HUD_CLICK_MESSAGE_COUNTER;
         }
         else if(source == MFSSendFlashGifts.REF_FLASH_GIFT)
         {
            this.m_source = source;
         }
         else
         {
            this.m_source = source;
         }
      }
      
      override public function perform() : void
      {
         signedCall("FarmExpressZMCService.sendGiftsFromFlash",this.m_giftCode,this.m_requestIds,this.m_ref,this.m_source,this.m_serverTime);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var uid:String = null;
         if(this.m_ref == REF_RECENTLY_PLAYED_GIFT && !Global.player.getSeenFlag(SEEN_FLAG_REQS2_RECENTLY_GIFTED))
         {
            Global.player.setSeenFlag(SEEN_FLAG_REQS2_RECENTLY_GIFTED);
         }
         if(result.hasOwnProperty("giftsSent") && result.giftsSent is Array)
         {
            for each(uid in result.giftsSent)
            {
               Global.player.sentGiftToUser(uid);
            }
         }
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

