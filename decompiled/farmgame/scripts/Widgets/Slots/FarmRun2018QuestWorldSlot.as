package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmRun2018MainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmRun2018QuestWorldSlot extends ZwSlotFrame
   {
      
      private var m_window:FarmRun2018MainWindow;
      
      protected var m_world:String = null;
      
      private var m_index:int = -1;
      
      private var m_completeIcon:MovieClip;
      
      private var m_lockIcon:MovieClip;
      
      private var m_profileIconFrame1:ZwFrame;
      
      private var m_ProfileIcon1:FarmIcon;
      
      private var m_profileIconFrame2:ZwFrame;
      
      private var m_ProfileIcon2:FarmIcon;
      
      private var m_profileIconFrame3:ZwFrame;
      
      private var m_ProfileIcon3:FarmIcon;
      
      private var m_iconTooltip:FarmTextTooltip;
      
      private const FEATURE_NAME:String = "FarmRunV10_2020";
      
      private var m_worldName:ZwTextField;
      
      private var m_travel_bt:FarmAnimatedTextButton;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_hitAreaMc:MovieClip;
      
      private var m_worldHitWidget:ZwFrame;
      
      public function FarmRun2018QuestWorldSlot(element:DisplayObject, window:FarmRun2018MainWindow)
      {
         var item:FarmItem = null;
         super(element);
         if(m_element.icon_mc != null)
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element.icon_mc));
            item = Global.farmGameSettingsManager.getFarmItemByName("consume_organic_fertilizer");
            this.m_iconMc.loadIcon(item.iconUrl);
            this.m_iconMc.visible = true;
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_worldName = new ZwTextField(element["name_tf"],"Something"));
            this.m_worldName.visible = true;
         }
         this.m_window = window;
         if(m_element.hasOwnProperty("travel_bt"))
         {
            this.m_travel_bt = new FarmAnimatedTextButton(element["travel_bt"],"Travel",this.onClickTravel);
            this.m_travel_bt.visible = false;
            this.m_travel_bt.enabled = false;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmarkMc = m_element.checkmark_mc as MovieClip;
            this.m_checkmarkMc.visible = true;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_element.lock_mc as MovieClip;
            this.m_lockMc.visible = true;
         }
         if(m_element.hasOwnProperty("hit_area_mc"))
         {
            this.m_worldHitWidget = new ZwFrame(m_element["hit_area_mc"] as MovieClip);
            this.m_worldHitWidget.visible = true;
            this.m_worldHitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
            this.m_worldHitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
         }
      }
      
      private function refreshSlotData() : void
      {
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_window.highlightWorldMc(m_index);
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_window.dimWorldMc(m_index);
         };
      }
      
      public function onClickTravel() : void
      {
      }
      
      override public function populate(data:Object) : void
      {
         this.m_world = data.world_code;
         this.m_index = data.index;
         var worldName:String = this.m_world;
         var worldFriendlyName:String = Global.worldManager.getWorldFriendlyName(worldName);
         if(worldName == "australia")
         {
            worldFriendlyName = ZLocUtils.t("FarmGame","World_Australia");
         }
         this.m_worldName.text = worldFriendlyName;
         this.m_worldName.visible = true;
         if(this.manager.isWorldCompleted(this.m_index))
         {
            this.m_lockMc.visible = false;
            this.m_checkmarkMc.visible = true;
         }
         else
         {
            this.m_lockMc.visible = true;
            this.m_checkmarkMc.visible = false;
         }
         if(this.manager.isWorldEnabled(this.m_index) && this.manager.getNPCProgress() < 1400)
         {
            this.m_travel_bt.enabled = true;
            this.m_travel_bt.visible = true;
            this.m_travel_bt.callback = this.manager.onTravelButtonClick(this.m_index);
            this.m_travel_bt.text = this.getTravelBtText();
            this.m_lockMc.visible = false;
            this.m_checkmarkMc.visible = false;
         }
         else
         {
            this.m_travel_bt.enabled = false;
            this.m_travel_bt.visible = false;
         }
         this.refreshSlotData();
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(this.FEATURE_NAME);
      }
      
      private function getTravelBtText() : String
      {
         var text:String = "Travel";
         if(Global.worldManager.currentWorldType == this.manager.getFarmrunWorldFromPoints())
         {
            text = "Enter";
         }
         return text;
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

