package Widgets
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.SameFeatureFriendsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmAnimatedTextButtonWithCallbackData;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class SameFeatureFriendsWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 30;
      
      private static const MAX_SLOTS:int = 6;
      
      public static const CLOSE_BUTTON_TIME:int = 5000;
      
      private const TITLE_SUFFIX:String = "_title";
      
      private const SUBTITLE_SUFFIX:String = "_subtitle";
      
      private const BTN_TEXT:String = "_btn_text";
      
      private const REQUEST_SENT_SUFFIX:String = "_request_sent_text";
      
      private const REQUEST_ACCEPTED_SUFFIX:String = "_request_accepted_text";
      
      private const SEND_REQUEST_SUFFIX:String = "_send_request_text";
      
      private const CLEAN_NEIGHBORS_WINDOW:String = "_clean_neighbors";
      
      private var m_cleanNeighbors:ZwFrame;
      
      public var m_slots:Dictionary = new Dictionary();
      
      public var m_frames:Dictionary = new Dictionary();
      
      private var m_loadingWindow:GenericPopup;
      
      private var ATTR_REQUEST_ACCEPTED:String = "requestAccepted";
      
      private var ATTR_REQUEST_SENT_TIME:String = "requestSentTime";
      
      private var m_featureName:String;
      
      private var m_loaderMC:ZwWidget;
      
      protected var closeButtonAddTimer:Timer = null;
      
      public function SameFeatureFriendsWindow(assetUrl:String, featureName:String)
      {
         super(assetUrl);
         this.m_featureName = featureName;
      }
      
      public function hideLoader() : void
      {
         this.m_loaderMC.visible = false;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_SUFFIX)));
         addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE_SUFFIX)));
         addWidget(this.m_loaderMC = new ZwWidget(m_window.mc_loader));
         this.makeCleanNeighborsNotificationOverlay();
         this.closeButtonAddTimer = new Timer(CLOSE_BUTTON_TIME,1);
         this.closeButtonAddTimer.addEventListener(TimerEvent.TIMER,this.closeButtonCallback);
         this.closeButtonAddTimer.start();
      }
      
      private function closeButtonCallback(e:TimerEvent) : void
      {
         this.addCloseButton();
      }
      
      private function addCloseButton() : void
      {
         if(m_closeButton)
         {
            m_closeButton.visible = true;
            if(this.closeButtonAddTimer != null)
            {
               this.closeButtonAddTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.addCloseButton);
               this.closeButtonAddTimer = null;
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function initSuggestionSlots(suggestedNeighbors:Object) : void
      {
         var frame:Dictionary = null;
         var i:int = 0;
         var slot:ZwFrame = null;
         this.removeSlotWidgets();
         if(m_window.mc_slotcontainer)
         {
            addWidget(new ZwFrame(m_window.mc_slotcontainer));
            for(i = 0; i < suggestedNeighbors.length; i++)
            {
               if(m_window.mc_slotcontainer["slot_" + i + "_mc"])
               {
                  frame = new Dictionary();
                  addWidget(slot = new ZwFrame(m_window.mc_slotcontainer["slot_" + i + "_mc"]) as ZwFrame,true);
                  slot.addWidget(frame["pic"] = new FarmIcon(slot.element.fbprofile_mc,suggestedNeighbors[i]["pic_square"]) as FarmIcon);
                  frame["pic"].x = 24;
                  frame["pic"].y = 18;
                  frame["pic"].setIconSize(60,60);
                  slot.addWidget(frame["name"] = new ZwTextField(slot.element.name_tf,suggestedNeighbors[i]["name"]));
                  slot.addWidget(frame["acceptedNotifier"] = new ZwWidget(slot.element.mc_checkmark) as ZwWidget,false);
                  slot.addWidget(frame["statusText"] = new ZwTextField(slot.element.description_tf,"Request Accepted"),false);
                  slot.addWidget(frame["btn"] = new FarmAnimatedTextButtonWithCallbackData(slot.element.add_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SEND_REQUEST_SUFFIX),this.onSendNeighborRequest,false,false,parseInt(suggestedNeighbors[i]["uid"])),false);
                  slot.addWidget(frame["sentNotifier"] = new ZwWidget(slot.element.mc_sent),false);
                  this.updateSlot(suggestedNeighbors[i],frame);
                  this.m_slots[suggestedNeighbors[i]["uid"]] = slot;
                  this.m_frames[suggestedNeighbors[i]["uid"]] = frame;
               }
            }
         }
         if(this.closeButtonAddTimer)
         {
            if(this.closeButtonAddTimer.running)
            {
               this.closeButtonAddTimer.stop();
            }
         }
         this.addCloseButton();
      }
      
      private function updateSlot(suggestedNeighbor:Object, frame:Dictionary) : void
      {
         frame["statusText"].text = "";
         if(suggestedNeighbor[this.ATTR_REQUEST_ACCEPTED])
         {
            frame["statusText"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REQUEST_ACCEPTED_SUFFIX);
            frame["statusText"].visible = true;
            frame["acceptedNotifier"].visible = true;
         }
         else if(suggestedNeighbor[this.ATTR_REQUEST_SENT_TIME])
         {
            frame["sentNotifier"].visible = true;
            frame["statusText"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REQUEST_SENT_SUFFIX);
            frame["statusText"].visible = true;
         }
         else
         {
            frame["btn"].visible = true;
         }
      }
      
      private function onSendNeighborRequest(e:Event, neighborIdObj:Object) : void
      {
         var neighborId:String = neighborIdObj.toString();
         this.m_frames[neighborId]["btn"].visible = false;
         this.m_frames[neighborId]["statusText"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REQUEST_SENT_SUFFIX);
         this.m_frames[neighborId]["sentNotifier"].visible = true;
         this.m_frames[neighborId]["statusText"].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REQUEST_SENT_SUFFIX);
         this.m_frames[neighborId]["statusText"].visible = true;
         this.notifyConsumableReceipt(this.m_slots[neighborId],this.manager.consumable.getImageByName("icon"));
         this.manager.sendNeighborRequest(neighborId);
      }
      
      public function notifyConsumableReceipt(slot:ZwFrame, iconUrl:String = "") : void
      {
         var message:String = null;
         var anchorObj:DisplayObject = null;
         var localPos:Point = null;
         var screen:Point = null;
         if(slot.element.consumableAdd_mc)
         {
            message = "+1";
            anchorObj = slot.element.add_bt;
            localPos = new Point(anchorObj.x + anchorObj.width * 0.75,anchorObj.y - anchorObj.height);
            screen = anchorObj.localToGlobal(localPos);
            UI.displayStatus(message,screen.x,screen.y,iconUrl,[new GlowFilter(16776960,1,8,8,20)],UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,UI.DEFAULT_STATUS_TWEEN_FONT_COLOR);
         }
      }
      
      private function makeCleanNeighborsNotificationOverlay() : void
      {
         addWidget(this.m_cleanNeighbors = new ZwFrame(m_window.message_mc),false);
         this.m_cleanNeighbors.addWidget(new ZwTextField(this.m_cleanNeighbors.element.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + this.CLEAN_NEIGHBORS_WINDOW + this.TITLE_SUFFIX)));
         this.m_cleanNeighbors.addWidget(new ZwTextField(this.m_cleanNeighbors.element.generic_tf,ZLocUtils.t("Dialogs",this.m_featureName + this.CLEAN_NEIGHBORS_WINDOW + this.SUBTITLE_SUFFIX)));
         this.m_cleanNeighbors.addWidget(new FarmButton(this.m_cleanNeighbors.element.close_bt,this.hideCleanNeighbors));
         this.m_cleanNeighbors.addWidget(new FarmAnimatedTextButton(this.m_cleanNeighbors.element.ok_bt,ZLocUtils.t("Dialogs",this.m_featureName + this.CLEAN_NEIGHBORS_WINDOW + this.BTN_TEXT),this.onCleanNeighborsClick));
      }
      
      private function onCleanNeighborsClick(e:Event) : void
      {
         this.manager.openNeighbors();
      }
      
      private function hideCleanNeighbors(e:Event) : void
      {
         this.m_cleanNeighbors.visible = false;
         this.close();
      }
      
      public function showCleanNeighbors() : void
      {
         this.m_cleanNeighbors.visible = true;
      }
      
      private function get manager() : SameFeatureFriendsManager
      {
         return SameFeatureFriendsManager.instance;
      }
      
      override protected function release() : void
      {
         this.removeSlotWidgets();
         this.m_cleanNeighbors = null;
         this.m_slots = null;
         this.m_frames = null;
         this.m_loadingWindow = null;
         this.manager.m_window = null;
         super.release();
      }
      
      private function removeSlotWidgets() : void
      {
         var slot:ZwFrame = null;
         var slotContainer:ZwFrame = null;
         var i:int = 0;
         if(m_window.mc_slotcontainer)
         {
            for(i = 0; i < MAX_SLOTS; i++)
            {
               if(m_window.mc_slotcontainer["slot_" + i + "_mc"])
               {
                  slot = getWidget(m_window.mc_slotcontainer["slot_" + i + "_mc"]) as ZwFrame;
                  if(slot)
                  {
                     removeWidget(slot);
                  }
                  slot = null;
               }
            }
            slotContainer = getWidget(m_window.mc_slotcontainer) as ZwFrame;
            if(slotContainer)
            {
               removeWidget(slotContainer);
               slotContainer = null;
            }
         }
      }
      
      override public function close() : void
      {
         this.manager.canOpenUI = true;
         super.close();
      }
   }
}

