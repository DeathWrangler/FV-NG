package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.JMInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class JMInnovationCraftConsumableSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private const TIMER_TF:String = "timer_tf";
      
      private const COUNTER_TF:String = "counter_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_slotIndex:int = 0;
      
      private var m_iconPreview:FarmIcon;
      
      private var m_timerTf:ZwTextField;
      
      private var m_counterTf:ZwTextField;
      
      private var m_state:int;
      
      private const TEXT_DESCRIPTION_LOCKED:String = "_locked_description_text";
      
      public function JMInnovationCraftConsumableSlot(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(this.m_timerTf = new ZwTextField(m_element[this.TIMER_TF]));
         }
         if(m_element.hasOwnProperty(this.COUNTER_TF))
         {
            addWidget(this.m_counterTf = new ZwTextField(m_element[this.COUNTER_TF]));
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconPreview = new FarmIcon(m_element[this.ICON_MC]));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var buildingItem:FarmItem = null;
         var toolTipText:String = null;
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.slotIndex;
         var state:int = this.manager.getStateForBuilding(this.m_slotIndex);
         var consumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
         var infoTooltip:FarmTextTooltip = new FarmTextTooltip(consumableItem.friendlyTitle);
         if(state == JMInnovationManager.STATE_LOCKED)
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(this.manager.buildingNameArray[this.m_slotIndex]);
            if(buildingItem)
            {
               toolTipText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.manager.buildingNameArray[this.m_slotIndex] + this.TEXT_DESCRIPTION_LOCKED);
               infoTooltip = new FarmTextTooltip(toolTipText);
            }
         }
         else if(state == JMInnovationManager.STATE_GATHER)
         {
            if(this.m_timerTf)
            {
               this.m_timerTf.visible = true;
               this.m_timerTf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftForSlot(this.m_slotIndex));
            }
         }
         this.m_counterTf.visible = true;
         var consumableCount:int = FeatureOptionsInventoryManager.getInstance().getCount(this.manager.ConsumableList[this.m_slotIndex]);
         var maxCount:int = int(this.manager.maxCountArray[this.m_slotIndex]);
         if(this.m_slotIndex == 0)
         {
            this.m_counterTf.text = "x" + consumableCount.toString();
         }
         else
         {
            this.m_counterTf.text = consumableCount.toString() + "/" + maxCount.toString();
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.visible = true;
            if(this.m_state == 0)
            {
               this.m_iconPreview.loadIcon(consumableItem.getImageByName("icon70"));
               this.m_iconPreview.attachTooltip(infoTooltip);
            }
         }
         (m_element as MovieClip).gotoAndStop(state);
         this.m_state = state;
      }
      
      private function get manager() : JMInnovationManager
      {
         return JMInnovationManager.getInstance(this.m_featureName);
      }
   }
}

