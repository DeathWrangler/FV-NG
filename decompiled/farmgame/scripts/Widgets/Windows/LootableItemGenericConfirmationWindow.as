package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LootableItemGenericConfirmationWindow extends FarmWindow
   {
      
      private static var OK:String = "LootableItemGenericConfirmationWindow_Okay";
      
      private var m_wonItem:FarmItem;
      
      private var m_lootableItemName:String;
      
      private var m_lootableItem:FarmItem;
      
      private var m_callback:Function;
      
      public function LootableItemGenericConfirmationWindow(lootableItemName:String, wonItem:FarmItem, closeCallback:Function = null)
      {
         super("assets/dialogs/FV_mysteryboxGeneric_Confirmation.swf",true);
         this.m_lootableItemName = lootableItemName;
         this.m_lootableItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_lootableItemName);
         this.m_wonItem = wonItem;
         this.m_callback = closeCallback;
         if(this.m_callback != null)
         {
            addEventListener(LootableItemGenericConfirmationWindow.OK,this.m_callback);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var itemXP:String = null;
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.mysteryBox_mc));
         var buttonText:String = ZLocUtils.t("Dialogs","Okay");
         addWidget(new FarmAnimatedTextButton(m_window.mysteryBox_mc.okay_bt,buttonText,this.onOkClick));
         var titleText:String = ZLocUtils.t("Dialogs",this.m_lootableItem.name + "_OpenedTitle");
         addWidget(new ZwTextField(m_window.mysteryBox_mc.title_tf,titleText));
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemXP = this.m_wonItem.getStringFromDataSource("XP");
         }
         else
         {
            itemXP = this.m_wonItem.xml.XP;
         }
         var bodyText:String = ZLocUtils.t("Dialogs",this.m_lootableItem.name + "_Opened",{
            "item":ZLocUtils.tk_pk(this.m_wonItem.friendlyName),
            "quantity":itemXP
         });
         addWidget(new ZwTextField(m_window.mysteryBox_mc.body1_tf,bodyText));
         addWidget(new FarmIcon(m_window.mysteryBox_mc.mysteryBoxIconLeft_mc,this.m_lootableItem.icon));
         addWidget(new FarmIcon(m_window.mysteryBox_mc.mysteryBoxIconRight_mc,this.m_lootableItem.icon));
         var prizeIcon:FarmIcon = new FarmIcon(m_window.mysteryBox_mc.icon_mc,this.m_wonItem.icon);
         var iconScale:Number = 0.5;
         prizeIcon.setIconScale(iconScale,iconScale);
         addWidget(prizeIcon);
      }
      
      private function onOkClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_callback != null)
         {
            dispatchEvent(new Event(LootableItemGenericConfirmationWindow.OK));
            removeEventListener(LootableItemGenericConfirmationWindow.OK,this.m_callback);
         }
         super.onClose(event);
         FarmStatsManager.count("got_loot","click_ok");
      }
   }
}

