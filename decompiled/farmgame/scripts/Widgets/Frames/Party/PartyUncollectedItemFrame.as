package Widgets.Frames.Party
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Party.BuildingPartyWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PartyUncollectedItemFrame extends PartyItemFrame
   {
      
      protected var m_parentWindow:BuildingPartyWindow;
      
      protected var m_target:int;
      
      protected var m_progress:int;
      
      public function PartyUncollectedItemFrame(element:DisplayObject, itemName:String, parentWindow:BuildingPartyWindow, goal:int, progress:int)
      {
         this.m_parentWindow = parentWindow;
         this.m_target = goal;
         this.m_progress = progress;
         super(element,itemName);
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         super.release();
      }
      
      override protected function setupIcon() : void
      {
         var itemIcon:FarmIcon = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
         if(farmItem)
         {
            itemIcon = new FarmIcon(element.icon_mc,farmItem.icon);
            itemIcon.setIconSize(65,65);
            itemIcon.x = 2;
            itemIcon.y = -5;
            addWidget(itemIcon);
         }
      }
      
      override protected function setupButton() : void
      {
         var acceptItemButton:FarmAnimatedTextButton = null;
         if(Global.farmGameSettingsManager.checkTimeGate(FarmGameUtil.synchronizedDateToNumber("12/1/2010"),FarmGameUtil.synchronizedDateToNumber("01/02/2011")))
         {
            acceptItemButton = addWidget(new FarmAnimatedTextButton(element.accept_bt,this.inviteText(),this.showGuestListFrame)) as FarmAnimatedTextButton;
         }
      }
      
      override protected function itemDescriptionText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_itemDescriptionText",{
            "quantity":this.m_progress,
            "quantityTotal":this.m_target
         });
      }
      
      private function buyNowText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_BuyNow");
      }
      
      private function inviteText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_Invite");
      }
      
      override protected function itemStateText() : String
      {
         return ZLocUtils.t("Dialogs","NYP_itemStateLocked");
      }
      
      protected function showGuestListFrame(event:Event) : void
      {
         this.m_parentWindow.m_toggleManager.performToggle(this.m_parentWindow.m_guestListToggle);
      }
   }
}

