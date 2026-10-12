package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.HolidayCountdownManager;
   import Widgets.Windows.Quests.WindowWithRewardItem;
   import flash.events.MouseEvent;
   
   public class CountdownRewardDialog extends WindowWithRewardItem
   {
      
      private var m_title:String;
      
      private var m_message:String;
      
      private var m_message2:String;
      
      public function CountdownRewardDialog(assetUrl:String, title:String, message:String, message2:String = "", bonusItem:FarmItem = null)
      {
         super(assetUrl,bonusItem);
         this.m_message = message;
         this.m_message2 = message2;
         this.m_title = title;
      }
      
      override protected function getTitle() : String
      {
         return this.m_title;
      }
      
      override protected function getRewardText() : String
      {
         return this.m_message;
      }
      
      override protected function getRewardShareButtonText() : String
      {
         return this.m_message2;
      }
      
      override protected function onShareClick(event:MouseEvent) : void
      {
         HolidayCountdownManager.onShareBonusDialogClose(null);
         super.onShareClick(event);
      }
   }
}

