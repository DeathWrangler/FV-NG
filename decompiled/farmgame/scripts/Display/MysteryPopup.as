package Display
{
   import Classes.LootableDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MysteryPopup extends Dialog
   {
      
      public static const ACCEPT:int = 1;
      
      public static const OK:int = 1;
      
      public static const YES:int = 1;
      
      public static const CANCEL:int = 0;
      
      public static const NO:int = 0;
      
      public static const TYPE_DESCRIBE:int = 0;
      
      public static const TYPE_CONFIRM:int = 1;
      
      public static const TYPE_MODAL:int = 3;
      
      public static var describeDialogOpen:Boolean = false;
      
      protected var m_iconLoader:Loader;
      
      protected var m_message:String;
      
      protected var m_type:int;
      
      protected var m_openGiftBox:Boolean = false;
      
      protected var m_closeCallback:Function;
      
      protected var m_accept:GenericButton;
      
      protected var m_reject:GenericButton;
      
      protected var m_acceptButtonText:String = "Buy";
      
      protected var m_popupValue:String = "";
      
      protected var m_item:FarmItem;
      
      protected var m_lootableItemName:String;
      
      public function MysteryPopup(type:int = 0, closeCallback:Function = null, item:FarmItem = null, lootableItemName:String = "mysterybox", openGiftBox:Boolean = false)
      {
         this.m_item = item;
         this.m_lootableItemName = lootableItemName;
         if(m_dialogAsset == null)
         {
            if(type == TYPE_DESCRIBE)
            {
               this.m_acceptButtonText = "Buy";
               m_dialogAsset = "assets/dialogs/FV_mysteryBox.swf";
               describeDialogOpen = true;
            }
            else
            {
               this.m_acceptButtonText = "Okay";
               m_dialogAsset = "assets/dialogs/FV_" + lootableItemName + "_Confirmation.swf";
            }
         }
         super();
         this.m_type = type;
         if(closeCallback != null)
         {
            this.m_closeCallback = closeCallback;
            addEventListener(GenericPopupEvent.SELECTED,closeCallback);
         }
         this.m_openGiftBox = openGiftBox;
      }
      
      override protected function onLoadComplete() : void
      {
         var xp:String = null;
         super.onLoadComplete();
         var data:Array = [];
         if(this.m_type == TYPE_DESCRIBE)
         {
            this.m_accept = new GenericButton(m_window.mysteryBox_mc.buy_bt,this.onAccept);
            this.m_accept.text = ZLocUtils.t("Dialogs",this.m_acceptButtonText);
            this.m_reject = new GenericButton(m_window.mysteryBox_mc.cancel_bt,this.onCancel);
            this.m_reject.text = ZLocUtils.t("Dialogs","Cancel");
            m_window.mysteryBox_mc.body_tf.text = LootableDecoration.getStringStatic("_Description",this.m_lootableItemName);
            m_window.mysteryBox_mc.title_tf.text = LootableDecoration.getStringStatic("_DescriptionTitle",this.m_lootableItemName);
         }
         else
         {
            this.m_accept = new GenericButton(m_window.mysteryBox_mc.okay_bt,this.onOkClick);
            this.m_accept.text = ZLocUtils.t("Dialogs",this.m_acceptButtonText);
            this.m_iconLoader = LoadingManager.load(this.m_item.getImageByName("icon"),this.onIconLoaded);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               xp = this.m_item.getStringFromDataSource("XP");
            }
            else
            {
               xp = this.m_item.xml.XP;
            }
            m_window.mysteryBox_mc.body1_tf.text = LootableDecoration.getStringStatic("_Opened",this.m_lootableItemName,{
               "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
               "quantity":xp
            });
            m_window.mysteryBox_mc.title_tf.text = LootableDecoration.getStringStatic("_OpenedTitle",this.m_lootableItemName);
         }
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.mysteryBox_mc.icon_mc;
         iconMc.scaleX = iconMc.scaleY = 0.75;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_iconLoader.content;
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         iconMc.addChild(newIcon);
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         describeDialogOpen = false;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,YES));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         close();
      }
      
      protected function onCancel(event:MouseEvent) : void
      {
         describeDialogOpen = false;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,NO));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         if(this.m_openGiftBox)
         {
            UI.displayGiftBoxWindow(false);
         }
         close();
      }
      
      protected function onOkClick(event:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,YES));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         event.stopPropagation();
         close();
         FarmStatsManager.count("got_loot","click_ok");
      }
      
      public function setAcceptText(txt:String) : void
      {
         if(this.m_accept)
         {
            this.m_accept.text = ZLocUtils.t("Dialogs",txt);
         }
         this.m_acceptButtonText = txt;
      }
      
      public function setPopupValue(val:String) : void
      {
         this.m_popupValue = val;
      }
   }
}

