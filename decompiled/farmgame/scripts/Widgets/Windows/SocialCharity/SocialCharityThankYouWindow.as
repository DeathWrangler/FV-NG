package Widgets.Windows.SocialCharity
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSocialCharityAction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SocialCharityThankYouWindow extends FarmWindow
   {
      
      private static const THANK_YOU_DIALOG:String = "thankyou_dialog";
      
      private var m_item:FarmItem;
      
      private var m_statsCounter:String;
      
      private var m_dialogPrefix:String;
      
      private var m_campaignName:String;
      
      public function SocialCharityThankYouWindow(itemName:String, campaignName:String, statsCounter:String, assetPath:String, dialogPrefix:String)
      {
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_statsCounter = statsCounter;
         this.m_dialogPrefix = dialogPrefix;
         this.m_campaignName = campaignName;
         super(assetPath);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var slotIcon:ObjectPreviewFrame = null;
         super.onLoadComplete(event);
         if(m_window.generic_tf != null)
         {
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,"LemonAidStand","thanks_title")));
         }
         if(m_window.generic2_tf != null)
         {
            addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,"LemonAidStand","thanks_giftbox")));
         }
         if(m_window.generic3_tf != null)
         {
            addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,"LemonAidStand","thanks_subtitle")));
         }
         if(m_window.share_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,"LemonAidStand","thanks_share"),this.onSharePersonalDonationClick));
         }
         if(m_window.icon_mc != null)
         {
            slotIcon = new ObjectPreviewFrame(m_window.icon_mc,this.m_item,null,null,[175]);
            addWidget(slotIcon);
         }
         FarmStatsManager.count(this.m_statsCounter,THANK_YOU_DIALOG,"impressions");
      }
      
      private function onSharePersonalDonationClick(event:Event = null) : void
      {
         TransactionManager.addTransaction(new TSocialCharityAction(this.postComplete,this.m_campaignName,"personalDonation" + this.m_item.code),true);
         FarmStatsManager.count("feed",this.m_statsCounter,"personalDonation");
         this.close();
      }
      
      private function postComplete(result:Object) : void
      {
         if(result.hasOwnProperty("postSuccessful") && result.postSuccessful == true)
         {
            FarmStatsManager.count(this.m_statsCounter,THANK_YOU_DIALOG,"share");
         }
      }
      
      override public function close() : void
      {
         FarmStatsManager.count(this.m_statsCounter,THANK_YOU_DIALOG,"close");
         super.close();
      }
   }
}

