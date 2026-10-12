package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationCraftingSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_manager:Object;
      
      private var m_coinTf:ZwTextField;
      
      private var m_craftIconMc:FarmIcon;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private var m_item0Mc:ZwFrame;
      
      private var m_count0Tf:ZwTextField;
      
      private var m_item1Mc:ZwFrame;
      
      private var m_count1Tf:ZwTextField;
      
      private var m_item2Mc:ZwFrame;
      
      private var m_count2Tf:ZwTextField;
      
      private var m_reIcon0Mc:FarmIcon;
      
      private var m_reIcon1Mc:FarmIcon;
      
      private var m_reIcon2Mc:FarmIcon;
      
      private var m_checkmark0mc:ZwWidget;
      
      private var m_checkmark1mc:ZwWidget;
      
      private var m_checkmark2mc:ZwWidget;
      
      private var m_coinageMc:MovieClip;
      
      private var m_tagMc:ZwWidget;
      
      private var m_name:String;
      
      private var m_recipeId:int;
      
      private var m_points:String;
      
      private var m_re0code:String;
      
      private var m_re1code:String;
      
      private var m_re2code:String;
      
      private var m_re0quant:String;
      
      private var m_re1quant:String;
      
      private var m_re2quant:String;
      
      private var m_asset:String;
      
      private const SERVICE_NAME:String = "FrontierInnovationService";
      
      private const COINAGE_MC:String = "coinage_mc";
      
      private const SpecialTagInfo:String = "Craft this item to sell it for 50% more Frontier Coins";
      
      private const TAG_MC:String = "tag_mc";
      
      public function FrontierInnovationCraftingSlot(element:DisplayObject, featureName:String, manager:Object)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_manager = manager;
         if(m_element.hasOwnProperty("coin_tf"))
         {
            this.m_coinTf = addWidget(new ZwTextField(m_element["coin_tf"],null)) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.COINAGE_MC))
         {
            this.m_coinageMc = m_element[this.COINAGE_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty("craft_icon_mc"))
         {
            addWidget(this.m_craftIconMc = new FarmIcon(m_element["craft_icon_mc"]));
         }
         if(m_element.hasOwnProperty("item0_mc"))
         {
            this.m_item0Mc = new ZwFrame(m_element["item0_mc"]);
            this.m_item0Mc.visible = false;
            if(m_element["item0_mc"].hasOwnProperty("count_tf"))
            {
               this.m_count0Tf = new ZwTextField(m_element["item0_mc"]["count_tf"]);
               this.m_count0Tf.visible = false;
            }
            if(m_element["item0_mc"].hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_reIcon0Mc = new FarmIcon(m_element["item0_mc"]["icon_mc"]));
               this.m_reIcon0Mc.visible = false;
            }
            if(m_element["item0_mc"].hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark0mc = addWidget(new ZwWidget(m_element["item0_mc"]["checkmark_mc"])) as ZwWidget;
               this.m_checkmark0mc.visible = false;
            }
         }
         if(m_element.hasOwnProperty("item1_mc"))
         {
            this.m_item1Mc = new ZwFrame(m_element["item1_mc"]);
            this.m_item1Mc.visible = false;
            if(m_element["item1_mc"].hasOwnProperty("count_tf"))
            {
               this.m_count1Tf = new ZwTextField(m_element["item1_mc"]["count_tf"]);
               this.m_count1Tf.visible = false;
            }
            if(m_element["item1_mc"].hasOwnProperty("icon_mc"))
            {
               this.m_reIcon1Mc = new FarmIcon(m_element["item1_mc"]["icon_mc"]);
               this.m_reIcon1Mc.visible = false;
            }
            if(m_element["item1_mc"].hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark1mc = new ZwWidget(m_element["item1_mc"]["checkmark_mc"]);
               this.m_checkmark1mc.visible = false;
            }
         }
         if(m_element.hasOwnProperty("item2_mc"))
         {
            this.m_item2Mc = new ZwFrame(m_element["item2_mc"]);
            this.m_item2Mc.visible = false;
            if(m_element["item2_mc"].hasOwnProperty("count_tf"))
            {
               this.m_count2Tf = new ZwTextField(m_element["item2_mc"]["count_tf"]);
               this.m_count2Tf.visible = false;
            }
            if(m_element["item2_mc"].hasOwnProperty("icon_mc"))
            {
               this.m_reIcon2Mc = new FarmIcon(m_element["item2_mc"]["icon_mc"]);
               this.m_reIcon2Mc.visible = false;
            }
            if(m_element["item2_mc"].hasOwnProperty("checkmark_mc"))
            {
               this.m_checkmark2mc = new ZwWidget(m_element["item2_mc"]["checkmark_mc"]);
               this.m_checkmark2mc.visible = false;
            }
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            addWidget(this.m_redeemBt = new FarmAnimatedTextButton(m_element["redeem_bt"],"Craft Now",this.addFeatureProgress));
         }
      }
      
      private function checkVisibilityOnCraft(resources:Object) : void
      {
         this.m_redeemBt.visible = true;
         this.m_redeemBt.enabled = resources[this.m_re0code] >= this.m_re0quant && resources[this.m_re1code] >= this.m_re1quant && resources[this.m_re2code] >= this.m_re2quant;
      }
      
      private function isRequiredResourceMore(required:int, total:int) : Boolean
      {
         return required >= total;
      }
      
      private function addFeatureProgress(evt:Event) : void
      {
         if(this.m_redeemBt.enabled)
         {
            this.m_redeemBt.enabled = false;
            FarmStatsManager.count(this.m_featureName,"CraftItem",this.m_name,this.m_points);
            FrontierInnovationManager.getInstance("FrontierInnovation").addFeatureProgressByCrafting(parseInt(this.m_points),this.m_recipeId);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var p:String = null;
         var q:String = null;
         var requiredResources:int = 0;
         var requiredResourceCount:int = 0;
         var itemHoverTooltip:FarmTextTooltip = null;
         var itemHoverTooltipRedeem:FarmTextTooltip = null;
         var item0:FarmItem = null;
         var resourceCount:String = null;
         var item1:FarmItem = null;
         var item2:FarmItem = null;
         var toolTipText:String = null;
         super.populate(data);
         this.m_recipeId = data[0].id;
         this.m_name = data[0].name;
         this.m_points = data[0].points;
         this.m_re0quant = data[0].re1quant;
         this.m_re1quant = data[0].re2quant;
         this.m_re2quant = data[0].re3quant;
         this.m_asset = data[0].asset;
         var basicResources:Object = FeatureOptionsManager.getInstance().getFeatureOption("FrontierInnovation","53");
         var luxuryResources:Object = FeatureOptionsManager.getInstance().getFeatureOption("FrontierInnovation","54");
         var resources:Object = {};
         for(p in basicResources)
         {
            resources[p] = basicResources[p];
         }
         for(q in luxuryResources)
         {
            resources[q] = luxuryResources[q];
         }
         requiredResources = 0;
         requiredResourceCount = 0;
         this.releaseRecipes();
         if(parseInt(this.m_re0quant) != 0)
         {
            requiredResources++;
            this.m_item0Mc.visible = true;
            this.m_count0Tf.visible = true;
            this.m_reIcon0Mc.visible = true;
            this.m_re0code = data[0].re1code;
            item0 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_re0code);
            this.m_reIcon0Mc.loadIcon(item0.icon);
            itemHoverTooltip = new FarmTextTooltip(item0.friendlyTitle);
            this.m_reIcon0Mc.attachTooltip(itemHoverTooltip);
            this.m_reIcon0Mc.visible = true;
            this.m_reIcon0Mc.setIconSize(40,40);
            resourceCount = resources[this.m_re0code];
            this.m_count0Tf.text = resourceCount + "/" + this.m_re0quant;
            this.m_count0Tf.visible = true;
            this.m_item0Mc.visible = true;
            if(this.isRequiredResourceMore(int(resourceCount),int(this.m_re0quant)))
            {
               requiredResourceCount++;
               this.m_checkmark0mc.visible = true;
            }
         }
         if(parseInt(this.m_re1quant) != 0)
         {
            requiredResources++;
            this.m_item1Mc.visible = true;
            this.m_count1Tf.visible = true;
            this.m_reIcon1Mc.visible = true;
            this.m_re1code = data[0].re2code;
            item1 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_re1code);
            this.m_reIcon1Mc.loadIcon(item1.icon);
            itemHoverTooltip = new FarmTextTooltip(item1.friendlyTitle);
            this.m_reIcon1Mc.attachTooltip(itemHoverTooltip);
            this.m_reIcon1Mc.visible = true;
            this.m_reIcon1Mc.setIconSize(40,40);
            this.m_count1Tf.text = resources[this.m_re1code] + "/" + this.m_re1quant;
            this.m_count1Tf.visible = true;
            this.m_item1Mc.visible = true;
            if(this.isRequiredResourceMore(int(resources[this.m_re1code]),int(this.m_re1quant)))
            {
               requiredResourceCount++;
               this.m_checkmark1mc.visible = true;
            }
         }
         if(parseInt(this.m_re2quant) != 0)
         {
            requiredResources++;
            this.m_item2Mc.visible = true;
            this.m_count2Tf.visible = true;
            this.m_reIcon2Mc.visible = true;
            this.m_re2code = data[0].re3code;
            item2 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_re2code);
            this.m_reIcon2Mc.loadIcon(item2.icon);
            itemHoverTooltip = new FarmTextTooltip(item2.friendlyTitle);
            this.m_reIcon2Mc.attachTooltip(itemHoverTooltip);
            this.m_reIcon2Mc.setIconSize(40,40);
            this.m_reIcon2Mc.visible = true;
            this.m_count2Tf.text = resources[this.m_re2code] + "/" + this.m_re2quant;
            this.m_count2Tf.visible = true;
            this.m_item2Mc.visible = true;
            if(this.isRequiredResourceMore(int(resources[this.m_re2code]),int(this.m_re2quant)))
            {
               requiredResourceCount++;
               this.m_checkmark2mc.visible = true;
            }
         }
         this.m_coinTf.text = this.m_points;
         this.m_coinTf.visible = true;
         this.m_craftIconMc.loadIcon(this.m_asset);
         this.m_craftIconMc.setIconSize(70,70);
         itemHoverTooltip = new FarmTextTooltip(this.m_name);
         this.m_craftIconMc.attachTooltip(itemHoverTooltip);
         this.m_craftIconMc.visible = true;
         this.m_redeemBt.visible = true;
         itemHoverTooltipRedeem = new FarmTextTooltip();
         var craftButtonVisibility:Boolean = requiredResourceCount == requiredResources;
         if(craftButtonVisibility)
         {
            this.m_redeemBt.attachTooltip(itemHoverTooltipRedeem);
            itemHoverTooltipRedeem.setText("Craft this recipe to get Frontier Coinage");
            this.m_redeemBt.enabled = craftButtonVisibility;
         }
         else
         {
            this.m_redeemBt.enabled = craftButtonVisibility;
            toolTipText = "Go Foraging to find resources to craft this item";
            FarmGameUtil.disableButtonAndShowTooltip(this.m_redeemBt,toolTipText);
         }
      }
      
      public function releaseRecipes() : void
      {
         this.m_craftIconMc.detachTooltip();
         this.m_item0Mc.visible = false;
         this.m_count0Tf.visible = false;
         this.m_reIcon0Mc.visible = false;
         this.m_reIcon0Mc.detachTooltip();
         this.m_checkmark0mc.visible = false;
         this.m_item1Mc.visible = false;
         this.m_count1Tf.visible = false;
         this.m_reIcon1Mc.visible = false;
         this.m_reIcon1Mc.detachTooltip();
         this.m_checkmark1mc.visible = false;
         this.m_item2Mc.visible = false;
         this.m_count2Tf.visible = false;
         this.m_reIcon2Mc.visible = false;
         this.m_reIcon2Mc.detachTooltip();
         this.m_checkmark2mc.visible = false;
         this.m_redeemBt.detachTooltip();
      }
   }
}

