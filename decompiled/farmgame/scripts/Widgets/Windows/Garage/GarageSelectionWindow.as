package Widgets.Windows.Garage
{
   import Classes.GarageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Garage.GarageSelectSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class GarageSelectionWindow extends FarmWindow
   {
      
      private const ICON_SIZE:Number = 50;
      
      private var m_garage:GarageBuilding;
      
      private var m_partsItem:FarmItem;
      
      private var m_upgradeCallback:Function;
      
      private var m_isGift:Boolean;
      
      public function GarageSelectionWindow(garage:GarageBuilding, partsItem:FarmItem, upgradeCallback:Function, isGift:Boolean)
      {
         super("assets/dialogs/FV_ChooseProject.swf");
         this.m_garage = garage;
         this.m_partsItem = partsItem;
         this.m_upgradeCallback = upgradeCallback;
         this.m_isGift = isGift;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemName:String = this.m_partsItem.friendlyName;
         addWidget(new ZwTextField(m_window.giftsTitle_tf,ZLocUtils.t("Dialogs","GarageSelectionTitle")));
         addWidget(new ZwTextField(m_window.chooseWhere_tf,ZLocUtils.t("Dialogs","GarageSelectionChooseVehicle",{"part":ZLocUtils.tk_pk(itemName)})));
         addWidget(new ZwTextField(m_window.itemTitle_tf,ZLocUtils.tk_pk_asTitle(itemName)));
         var itemIcon:FarmIcon = new FarmIcon(m_window.icon,this.m_partsItem.icon);
         itemIcon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         addWidget(itemIcon);
         addWidget(new FarmAnimatedButton(m_window.cancel_bt,onClose));
         addWidget(new GarageSelectSlotFrame(m_window.projectSelector_mc,this.m_garage,this.m_upgradeCallback,this,this.m_isGift));
      }
      
      public function get garage() : GarageBuilding
      {
         return this.m_garage;
      }
   }
}

