package Transactions
{
   import Classes.LootableDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Display.UnwitherRingDetails;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class TOpenValentinesPresent extends TOpenLootItem
   {
      
      protected static const BOXOPEN_URL:String = "assets/effects/effect_stars_burst.swf";
      
      protected var m_extraItemData:Object;
      
      protected var m_senderUID:String = "";
      
      public function TOpenValentinesPresent(lootItem:LootableDecoration)
      {
         super(lootItem);
         m_lootItem.centerOn();
      }
      
      override public function perform() : void
      {
         signedWorldAction("open");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var itemName:String = null;
         var senderId:String = null;
         if(m_popup)
         {
            m_popup.close();
         }
         if(result)
         {
            if(result.item)
            {
               itemName = result.item.toString();
               senderId = result.giftSenderId;
               this.m_extraItemData = result.extraItemData;
               Global.player.addGift(itemName,senderId);
               m_wonItemName = itemName;
               TweenLite.to(this,0.2,{
                  "m_dummy":0,
                  "onComplete":this.startMCPlaying
               });
            }
            else if(result.error)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs",m_lootItem.itemName + "_" + result.error));
            }
         }
      }
      
      override protected function startMCPlaying() : void
      {
         var screen:Vector2 = IsoMath.tilePosToPixelPos(m_lootItem.getPosition().x,m_lootItem.getPosition().y,m_lootItem.getPosition().z);
         var pt:Point = new Point(screen.x,screen.y);
         Global.ui.displayOverlaySWF(Global.getAssetURL(BOXOPEN_URL),pt,null,-100,this.onMCFinishPlaying);
      }
      
      override protected function onMCFinishPlaying() : Boolean
      {
         var senderName:String = null;
         var senderGender:String = null;
         var dialogTitle:String = null;
         var dialogText:String = null;
         var dialog:GenericPopupTitle = null;
         var text:String = null;
         m_lootItem.detach();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(m_wonItemName);
         if(this.m_extraItemData)
         {
            this.m_senderUID = this.m_extraItemData.sender;
            if(this.m_senderUID != Global.player.uid)
            {
               UI.displayPopup(new UnwitherRingDetails(this.m_extraItemData.sender,this.m_extraItemData.ringType,this.m_extraItemData.message));
               senderName = Global.friendManager.getFriendName(this.m_extraItemData.sender);
               senderGender = Global.friendManager.getFriendGender(this.m_extraItemData.sender);
               dialogTitle = ZLocUtils.t("Dialogs","ThankYou");
               dialogText = ZLocUtils.t("Dialogs","ValentinesPresentThankYou",{
                  "user":ZLocUtils.tn(senderName,ZLocUtils.tg(senderGender)),
                  "user_same":senderName
               });
               dialog = new GenericPopupTitle(dialogTitle,dialogText,true,GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseFeedPrompt);
               UI.displayPopup(dialog);
            }
            else
            {
               text = ZLocUtils.t("Dialogs","ringboxOpened");
               UI.displayMessage(text);
            }
         }
         return false;
      }
      
      private function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            bundleData = {
               "actor":Global.player.snUser.firstName,
               "images":[{
                  "href":"{SN_APP_URL}{creative:recipient_thankyougift}index.php",
                  "src":Global.getAssetURL("assets/newsfeed/valentine.png")
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("ValentinesPresentThankYou",bundleData,[this.m_senderUID],false,null);
            FarmStatsManager.count("Recipient","Thankyougift");
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         m_popup.close();
      }
   }
}

