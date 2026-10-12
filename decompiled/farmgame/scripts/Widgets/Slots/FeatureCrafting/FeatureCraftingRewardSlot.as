package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingInventoryPart;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingRewardSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingRewardSlot extends ZwSlotFrame
   {
      
      private static const ICON_URL_COIN:String = "assets/decorations/fv_coin_icon.png";
      
      private static const ICON_URL_XP:String = "assets/decorations/fv_xp_icon.png";
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_countTextField:ZwTextField;
      
      public function FeatureCraftingRewardSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_countTextField = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var parent:FeatureCraftingRewardSlotContainerFrame = null;
         var system:FeatureCraftingSystem = null;
         var partName:String = null;
         var part:FeatureCraftingInventoryPart = null;
         var tooltipText:String = null;
         var itemName:String = null;
         var item:FarmItem = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            parent = getAncestorByClassType(FeatureCraftingRewardSlotContainerFrame) as FeatureCraftingRewardSlotContainerFrame;
            system = parent.system;
            switch(this.m_data.type)
            {
               case FeatureCraftingSystem.REWARDS_TYPE_COIN:
                  this.m_icon.loadIcon(ICON_URL_COIN);
                  (this.m_icon.tooltip as FarmTextTooltip).setText("Coins");
                  this.m_countTextField.text = String(this.m_data[FeatureCraftingSystem.REWARDS_AMOUNT]);
                  break;
               case FeatureCraftingSystem.REWARDS_TYPE_POINTS:
                  this.m_icon.loadIcon(system.getAssetUrl(FeatureCraftingSystem.ASSET_ICON_POINTS));
                  (this.m_icon.tooltip as FarmTextTooltip).setText(system.getPointsFriendlyTitle());
                  this.m_countTextField.text = String(this.m_data[FeatureCraftingSystem.REWARDS_AMOUNT]);
                  break;
               case FeatureCraftingSystem.REWARDS_TYPE_INVENTORYPARTS:
                  partName = this.m_data[FeatureCraftingSystem.REWARDS_VALUE];
                  part = system.getInventoryPart(partName);
                  if(part)
                  {
                     tooltipText = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"PartTooltip",{
                        "partName":part.friendlyTitle,
                        "storageName":part.inventory.friendlyTitle
                     });
                     this.m_icon.loadIcon(part.iconUrl);
                     (this.m_icon.tooltip as FarmTextTooltip).setText(tooltipText);
                     this.m_countTextField.text = "x" + this.m_data[FeatureCraftingSystem.REWARDS_AMOUNT];
                  }
                  break;
               case FeatureCraftingSystem.REWARDS_TYPE_ITEMGRANT:
                  itemName = this.m_data[FeatureCraftingSystem.REWARDS_VALUE];
                  item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                  if(item)
                  {
                     this.m_icon.loadIcon(item.iconUrl);
                     (this.m_icon.tooltip as FarmTextTooltip).setText(item.friendlyTitle);
                     this.m_countTextField.text = "x" + this.m_data[FeatureCraftingSystem.REWARDS_AMOUNT];
                  }
            }
            this.m_icon.visible = true;
            this.m_countTextField.visible = true;
         }
      }
   }
}

