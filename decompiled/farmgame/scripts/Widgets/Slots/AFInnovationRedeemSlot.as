package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.AFInnovationManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.AFInnovationRedeemWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AFInnovationRedeemSlot extends ZwSlotFrame
   {
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private var m_data:Object;
      
      protected var m_item:FarmItem = null;
      
      private var m_featureName:String;
      
      private const TRADE_BT:String = "trade_bt";
      
      private var m_slotIndex:Number = 0;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_parentWindow:AFInnovationRedeemWindow;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private var m_checkMark:MovieClip = null;
      
      private const COUNT_TF:String = "count_tf";
      
      public function AFInnovationRedeemSlot(element:DisplayObject, featureName:String, parentWindow:AFInnovationRedeemWindow)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_parentWindow = parentWindow;
         if(m_element.slot_icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.slot_icon_mc));
         }
         if(m_element[this.CONSUMABLE_MC].icon_mc != null)
         {
            addWidget(new FarmIcon(m_element[this.CONSUMABLE_MC].icon_mc));
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkMark = m_element[this.CHECKMARK_MC] as MovieClip;
            this.m_checkMark.visible = false;
         }
         if(m_element.hasOwnProperty(this.TRADE_BT))
         {
            this.m_redeemButton = new FarmAnimatedTextButton(m_element[this.TRADE_BT],"Redeem",this.onRedeemItem);
            this.m_redeemButton.visible = true;
            this.m_redeemButton.enabled = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemBox:FarmIcon = null;
         var attachedToolTip:FarmTextTooltip = null;
         this.m_data = data;
         this.m_slotIndex = this.m_data.rewardSlotNumber;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.rewardName);
         if(Boolean(m_element) && Boolean(m_element["slot_icon_mc"]))
         {
            itemBox = getWidget(m_element["slot_icon_mc"]) as FarmIcon;
            if(itemBox)
            {
               itemBox.loadIcon(this.m_item.icon);
               itemBox.visible = true;
               attachedToolTip = itemBox.tooltip as FarmTextTooltip;
               if(attachedToolTip)
               {
                  itemBox.detachTooltip();
               }
               itemBox.attachTooltip(new FarmTextTooltip(this.m_item.friendlyTitle));
            }
         }
         if(m_element.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumable_mc = m_element[this.CONSUMABLE_MC] as MovieClip;
            if(this.m_consumable_mc)
            {
               this.m_consumable_mc.visible = true;
               this.m_consumable_mc[this.COUNT_TF].text = "x" + AFInnovationManager.getInstance().getRewardCostArray()[this.m_slotIndex].toString();
            }
         }
         if(this.m_redeemButton)
         {
            this.m_redeemButton.enabled = AFInnovationManager.getInstance().isRewardRedeemable(this.m_slotIndex);
         }
         this.m_checkMark.visible = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(AFInnovationManager.FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureData)
         {
            if(Boolean(featureData.hasOwnProperty(AFInnovationManager.FEATURE_OPTIONS_COLLECT_KEY)) && Boolean(featureData[AFInnovationManager.FEATURE_OPTIONS_COLLECT_KEY].hasOwnProperty(this.m_item.name)) && featureData[AFInnovationManager.FEATURE_OPTIONS_COLLECT_KEY][this.m_item.name] == 1)
            {
               this.m_checkMark.visible = true;
            }
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Rewards_UI","redeem_click");
         AFInnovationManager.getInstance(this.m_featureName).redeemItem(this.m_data.rewardName,this.m_slotIndex,this.m_parentWindow);
      }
   }
}

