package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmRunV5MainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmRunV5QuestWorldSlot extends ZwSlotFrame
   {
      
      private var m_window:FarmRunV5MainWindow;
      
      protected var m_world:String = null;
      
      private var m_index:int = -1;
      
      private var m_featureName:String;
      
      private var m_worldName:ZwTextField;
      
      private var m_travel_bt:FarmAnimatedTextButton;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_worldHitWidget:ZwFrame;
      
      public function FarmRunV5QuestWorldSlot(element:DisplayObject, window:FarmRunV5MainWindow, featureName:String)
      {
         var item:FarmItem = null;
         super(element);
         this.m_featureName = featureName;
         this.m_window = window;
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
         if(m_element.hasOwnProperty("travel_bt"))
         {
            this.m_travel_bt = new FarmAnimatedTextButton(element["travel_bt"],"Travel",null);
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
      
      override public function populate(data:Object) : void
      {
         this.m_world = data.world_code;
         this.m_index = data.index;
         var worldName:String = this.m_world;
         var worldFriendlyName:String = Global.worldManager.getWorldFriendlyName(worldName);
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
         if(this.manager.isWorldEnabled(this.m_index) && this.manager.getFeatureProgress() < 1000)
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
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
      }
      
      private function getTravelBtText() : String
      {
         return Global.worldManager.currentWorldType == this.manager.getFarmrunWorldFromPoints() ? "Enter" : "Travel";
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

