package Widgets.Windows.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BBushel;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialog;
   import Display.GenericButton;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   
   public class CropBoostWindow extends Dialog
   {
      
      protected static var m_isOpen:Boolean = false;
      
      public static const TWEEN_TIME:Number = 0.5;
      
      private var m_iconLoader:Loader;
      
      protected var m_bushelCode:String;
      
      protected var m_bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelCode);
      
      protected var m_cropItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelItem.crop);
      
      private var m_acceptButton:GenericButton;
      
      private var m_cancelButton:GenericButton;
      
      private var m_OnCropUsedCallBack:Function;
      
      private var m_cropBuffType:int = BBushel.getEligibleBushelBuffType(this.m_cropItem.code);
      
      public function CropBoostWindow(bushelCode:String, onCropUsedCallback:Function)
      {
         m_dialogAsset = "assets/dialogs/FV_MarketStall_CropBoost.swf";
         this.m_bushelCode = bushelCode;
         this.m_OnCropUsedCallBack = onCropUsedCallback;
         super(true);
      }
      
      public static function get isOpen() : Boolean
      {
         return m_isOpen;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.m_iconLoader = LoadingManager.load(this.m_cropItem.icon,this.onIconLoaded);
         m_window.popupBox_mc.lockIcon_mc.visible = this.m_cropBuffType == BBushel.TYPE_LICENSE;
         m_window.popupBox_mc.masteryIcon_mc.visible = this.m_cropBuffType == BBushel.TYPE_MASTERY;
         m_window.popupBox_mc.xpIcon_mc.visible = this.m_cropBuffType == BBushel.TYPE_CROPEXP;
         m_window.popupBox_mc.accept_bt.visible = false;
         this.m_acceptButton = new GenericButton(m_window.popupBox_mc.start_bt,this.onAcceptClick);
         this.m_acceptButton.text = ZLocUtils.t("Crafting","CropBonusDialog_StartBonus");
         this.m_cancelButton = new GenericButton(m_window.popupBox_mc.keep_bt,this.onCancelClick);
         this.m_cancelButton.text = ZLocUtils.t("Crafting","CropBonusDialog_Cancel");
         this.setupText();
      }
      
      private function renderAcceptPresentation() : void
      {
         var crop:FarmItem = null;
         var friendlyTime:String = null;
         var bushelItem:FarmItem = null;
         var itemXML:XML = null;
         var seedCode:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelCode);
            crop = Global.farmGameSettingsManager.getFarmItemByCode(bushelItem.crop);
         }
         else
         {
            itemXML = Global.farmGameSettingsManager.getItemXMLByCode(this.m_bushelCode);
            seedCode = itemXML.crop;
            crop = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         }
         var timeArray:Array = FarmGameUtil.parseTimeLeftZLoc(BBushel.getBuffDuration());
         if(timeArray["Days"] > 0)
         {
            if(timeArray["Hours"] > 0)
            {
               friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeDaysHours",{
                  "dayNum":timeArray["Days"],
                  "hourNum":timeArray["Hours"]
               });
            }
            else
            {
               friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeDays",{"dayNum":timeArray["Days"]});
            }
         }
         else if(timeArray["Hours"] > 0)
         {
            if(timeArray["Minutes"] > 0)
            {
               friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeHoursMins",{
                  "hourNum":timeArray["Hours"],
                  "minuteNum":timeArray["Minutes"]
               });
            }
            else
            {
               friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeHours",{"hourNum":timeArray["Hours"]});
            }
         }
         else if(timeArray["Minutes"] > 0)
         {
            friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeMinsSecs",{
               "minuteNum":timeArray["Minutes"],
               "secondNum":timeArray["Seconds"]
            });
         }
         else
         {
            friendlyTime = ZLocUtils.t("Crafting","Expires_FriendlyTimeSecs",{"secondNum":timeArray["Seconds"]});
         }
         m_window.popupBox_mc.popupBox_tf.htmlText = ZLocUtils.t("Crafting","CropBonusDialog_Type" + this.m_cropBuffType,{
            "seed":ZLocUtils.tk_pk(crop.friendlyName),
            "seed_same":ZLocUtils.tk_pk(crop.friendlyName),
            "expiresStr":friendlyTime
         });
      }
      
      private function renderConflictPresentation() : void
      {
         var seedCode:String = null;
         var item:FarmItem = null;
         var itemXML:XML = null;
         m_window.popupBox_mc.popupBox_tf.htmlText = "Conflict!";
         var existingBuff:BBushel = new BBushel("BBushel");
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelCode);
            seedCode = item.crop;
         }
         else
         {
            itemXML = Global.farmGameSettingsManager.getItemXMLByCode(this.m_bushelCode);
            seedCode = itemXML.crop;
         }
         var crop:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(seedCode);
         var cropBonusDialogKey:String = "CropBonusDialog_Conflict_Type" + existingBuff.buffType;
         m_window.popupBox_mc.popupBox_tf.htmlText = ZLocUtils.t("Crafting",cropBonusDialogKey,{
            "crop_bonus":ZLocUtils.tk_pk(existingBuff.seedFriendlyName),
            "boost_name":ZLocUtils.tk_pk(crop.friendlyName)
         });
      }
      
      private function setupText() : void
      {
         var existingBuff:BBushel = null;
         if(Global.player.buffs["BBushel"] != null)
         {
            existingBuff = new BBushel("BBushel");
         }
         if(existingBuff != null && !existingBuff.isExpired())
         {
            this.renderConflictPresentation();
         }
         else
         {
            this.renderAcceptPresentation();
         }
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         if(this.m_OnCropUsedCallBack != null)
         {
            this.m_OnCropUsedCallBack(this.m_bushelCode);
         }
         close();
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
      }
      
      private function closeWindow() : void
      {
         m_window.popupBox_mc.start_bt.removeEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_window.popupBox_mc.keep_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_acceptButton = null;
         this.m_cancelButton = null;
         this.m_OnCropUsedCallBack = null;
         close();
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.popupBox_mc.icon_mc;
         iconMc.scaleX = iconMc.scaleY = 0.7;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_iconLoader.content;
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         iconMc.addChild(newIcon);
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            m_cursorId = UI.setCursor(null);
            this.centerPopup();
            Utilities.toggleInputAndChildren(this,true);
            m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,onResize);
         }
         else
         {
            m_showOnLoad = true;
         }
         SoundManager.playSound("dialogSpawn");
      }
      
      override protected function onHide() : void
      {
         if(m_shown == true)
         {
            m_shown = false;
            Utilities.toggleInputAndChildren(this,false);
            UI.removeCursor(m_cursorId);
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.removeEventListener(Event.RESIZE,onResize);
         }
         m_showOnLoad = false;
      }
   }
}

