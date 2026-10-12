package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.JMInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   
   public class JMInnovationHarvestStationSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_slotIndex:int;
      
      private const NAME_TF:String = "name_tf";
      
      private const LEVEL_TF:String = "level_tf";
      
      private const GATHERER_MC:String = "gatherer_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const SEND_BT:String = "send_bt";
      
      private const BUY_BT:String = "buy_bt";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const MULTIPLLIER_TF:String = "multiplier_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_sendButton:FarmAnimatedTextButton;
      
      private var m_nameTf:ZwTextField;
      
      private var m_levelTf:ZwTextField;
      
      private var m_timerTf:ZwTextField;
      
      private var m_descTf:ZwTextField;
      
      private var m_buildingFrame:ResourcePreviewFrame;
      
      private var m_consumableFrame:ZwFrame;
      
      private var m_iconPreview:FarmIcon;
      
      private var m_multiplierTf:ZwTextField;
      
      private var m_window:FarmWindow;
      
      private var m_state:int;
      
      private const TEXT_COLLECT_HOVER:String = "_send_collect_button_hover";
      
      private const TEXT_SEND_HOVER:String = "_gatherer_send_button_hover";
      
      private const TEXT_DESCRIPTION:String = "_description_text";
      
      private const TEXT_LEVEL_DESCRIPTION:String = "_level_description_text";
      
      private const TEXT_DESCRIPTION_LOCKED:String = "_locked_description_text";
      
      private const TEXT_LEVEL:String = "_level_text";
      
      private const X:String = "x";
      
      public function JMInnovationHarvestStationSlot(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         if(m_element.hasOwnProperty(this.NAME_TF))
         {
            addWidget(this.m_nameTf = new ZwTextField(m_element[this.NAME_TF]));
         }
         if(m_element.hasOwnProperty(this.LEVEL_TF))
         {
            addWidget(this.m_levelTf = new ZwTextField(m_element[this.LEVEL_TF]));
         }
         if(m_element.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(this.m_timerTf = new ZwTextField(m_element[this.TIMER_TF]));
         }
         if(m_element.hasOwnProperty(this.DESCRIPTION_TF))
         {
            addWidget(this.m_descTf = new ZwTextField(m_element[this.DESCRIPTION_TF]));
         }
         if(m_element.hasOwnProperty(this.SEND_BT))
         {
            addWidget(this.m_sendButton = new FarmAnimatedTextButton(m_element[this.SEND_BT],"Send",this.onClickSend));
         }
         if(m_element.hasOwnProperty(this.CONSUMABLE_MC))
         {
            addWidget(this.m_consumableFrame = new ZwFrame(m_element[this.CONSUMABLE_MC]));
            if(this.m_consumableFrame.element.hasOwnProperty(this.MULTIPLLIER_TF))
            {
               addWidget(this.m_multiplierTf = new ZwTextField(this.m_consumableFrame.element[this.MULTIPLLIER_TF],"x10"));
            }
            if(this.m_consumableFrame.element.hasOwnProperty(this.ICON_MC))
            {
               addWidget(this.m_iconPreview = new FarmIcon(this.m_consumableFrame.element[this.ICON_MC]));
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var level:XML = null;
         var nextLevel:int = 0;
         var nextQuantity:int = 0;
         var exportName:String = null;
         super.populate(data);
         this.m_data = data;
         var state:int = this.manager.getStateForBuilding(data.slotIndex);
         var buildingItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(data.name);
         var consumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.ConsumableList[data.slotIndex]);
         this.m_slotIndex = this.m_data.slotIndex;
         if(this.m_nameTf)
         {
            this.m_nameTf.visible = true;
            this.m_nameTf.text = buildingItem.friendlyTitle;
         }
         if(this.m_levelTf)
         {
            this.m_levelTf.visible = true;
            this.m_levelTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,data.name + this.TEXT_LEVEL,{"level":data.level});
            if(data.level > 1)
            {
               this.m_levelTf.text += "s";
            }
         }
         if(this.m_descTf)
         {
            this.m_descTf.visible = true;
            level = this.manager.getLevelXml(this.m_data.name);
            if(level != null && level.hasOwnProperty("@nextLevel"))
            {
               nextLevel = parseInt(level["@nextLevel"]);
               nextQuantity = parseInt(level["@nextQuantity"]);
               this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,data.name + this.TEXT_LEVEL_DESCRIPTION,{
                  "level":nextLevel,
                  "quantity":nextQuantity
               });
            }
            else
            {
               this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,data.name + this.TEXT_DESCRIPTION);
            }
            if(state == JMInnovationManager.STATE_LOCKED)
            {
               this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,data.name + this.TEXT_DESCRIPTION_LOCKED);
            }
         }
         if(this.m_sendButton)
         {
            this.m_sendButton.visible = true;
            if(state == JMInnovationManager.STATE_IDLE)
            {
               this.m_sendButton.text = "Send";
               this.m_sendButton.enabled = true;
               this.m_sendButton.detachTooltip();
               this.m_sendButton.callback = this.onClickSend;
               if(this.manager.hasMaxCapReacheadForSlot(this.m_slotIndex))
               {
                  this.m_sendButton.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_sendButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_SEND_HOVER));
               }
            }
            else if(state == JMInnovationManager.STATE_COLLECT || state == JMInnovationManager.STATE_GATHER)
            {
               this.m_sendButton.text = "Collect";
               this.m_sendButton.enabled = true;
               this.m_sendButton.detachTooltip();
               this.m_sendButton.callback = this.onClickCollect;
               if(state == JMInnovationManager.STATE_GATHER)
               {
                  this.m_sendButton.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_sendButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLLECT_HOVER));
               }
            }
            else if(state == JMInnovationManager.STATE_LOCKED)
            {
               this.m_sendButton.visible = false;
            }
         }
         if(m_element.hasOwnProperty(this.GATHERER_MC) && this.m_state != state)
         {
            exportName = this.manager.getExportNamePrefix(this.m_data.slotIndex) + this.manager.getExportNameSuffix(state,this.m_state);
            this.m_buildingFrame = new ResourcePreviewFrame(m_element[this.GATHERER_MC],this.manager.buildingMovieClip(this.m_data.slotIndex),exportName);
            this.m_buildingFrame.visible = true;
            if(state == JMInnovationManager.STATE_LOCKED)
            {
               (this.m_buildingFrame.element as MovieClip).filters = [new ColorMatrixFilter(FarmGameUtil.getSaturationMatrix(0))];
            }
         }
         if(this.m_consumableFrame)
         {
            this.m_consumableFrame.visible = true;
            if(this.m_iconPreview)
            {
               this.m_iconPreview.visible = true;
               if(this.m_state == 0)
               {
                  this.m_iconPreview.loadIcon(consumableItem.getImageByName("icon70"));
               }
               (this.m_consumableFrame.element as MovieClip).gotoAndStop(state);
            }
            if(Boolean(this.m_multiplierTf) && state != JMInnovationManager.STATE_LOCKED)
            {
               this.m_multiplierTf.visible = true;
               this.m_multiplierTf.text = this.X + this.manager.getRewardCount(this.m_data.name);
            }
         }
         this.m_state = state;
      }
      
      private function get manager() : JMInnovationManager
      {
         return JMInnovationManager.getInstance(this.m_featureName);
      }
      
      private function onClickSend(event:Event) : void
      {
         this.manager.GatherConsumable(this.m_slotIndex);
         var buildingName:String = this.manager.buildingNameArray[this.m_slotIndex];
         FarmStatsManager.count(this.m_featureName,"feature_ui",buildingName + "_send","click");
         this.populate(this.m_data);
         this.m_window.refreshWindow();
      }
      
      private function onClickCollect(event:Event) : void
      {
         this.manager.collectConsumable(this.m_slotIndex);
         var buildingName:String = this.manager.buildingNameArray[this.m_slotIndex];
         FarmStatsManager.count(this.m_featureName,"feature_ui",buildingName + "_collect","click");
         this.populate(this.m_data);
         this.m_window.refreshWindow();
      }
   }
}

