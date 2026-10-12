package Widgets.Slots.SeedDispenser
{
   import Classes.FeatureDataObjects.SeedDispenserSeedConfig;
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Managers.SeedDispenserManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.SeedDispenser.SeedDispenserContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class SeedDispenserContentsSlot extends ZwSlotFrame
   {
      
      private static const SLOT_ICON_WIDTH:int = 82;
      
      private static const SLOT_ICON_HEIGHT:int = 131;
      
      protected var m_parentWindow:SeedDispenserContentsWindow;
      
      protected var m_data:SeedDispenserSeedConfig;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_lockWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_tooltipTextField:ZwTextField;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      public function SeedDispenserContentsSlot(element:DisplayObject, parentWindow:SeedDispenserContentsWindow)
      {
         var hitWidget:ZwWidget = null;
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(SLOT_ICON_WIDTH,SLOT_ICON_HEIGHT);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         this.m_lockWidget = addWidget(new ZwWidget(m_element.lock_mc)) as ZwWidget;
         if(m_element.hit_bt)
         {
            hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (hitWidget.element as SimpleButton).useHandCursor = false;
            hitWidget.visible = true;
         }
         var tooltipFrame:ZwFrame = new ZwFrame(m_element.tooltip_mc) as ZwFrame;
         this.m_nameTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.name_tf," ")) as ZwTextField;
         this.m_tooltipTextField = tooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.generic_tf," ")) as ZwTextField;
         this.m_useButton = tooltipFrame.addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.use_bt,ZLocUtils.t("Dialogs","SeedDispenser_UseSeeds"),this.onUseButtonClick)) as FarmAnimatedTextButton;
         this.m_buyButton = tooltipFrame.addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.buy_bt,ZLocUtils.t("Dialogs","SeedDispenser_BuySeeds"),this.onBuyButtonClick)) as FarmAnimatedTextButton;
         var tooltip:WidgetTooltip = new WidgetTooltip(tooltipFrame);
         tooltip.fixed = true;
         tooltip.interactive = true;
         attachTooltip(tooltip);
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_icon = null;
         this.m_checkWidget = null;
         this.m_lockWidget = null;
         this.m_nameTextField = null;
         this.m_tooltipTextField = null;
         this.m_useButton = null;
         this.m_buyButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var seedItem:SeedItem = null;
         var mastery:Mastery = null;
         var isMastered:Boolean = false;
         var seedCount:int = 0;
         var activeSeedConfig:SeedDispenserSeedConfig = null;
         var isActiveSeed:Boolean = false;
         var nextSeedConfig:SeedDispenserSeedConfig = null;
         var nextSeedItem:FarmItem = null;
         var previousSeedConfig:SeedDispenserSeedConfig = null;
         var previousSeedItem:FarmItem = null;
         super.populate(data);
         this.m_data = data as SeedDispenserSeedConfig;
         if(this.m_data)
         {
            this.m_icon.loadIcon(Global.getAssetURL(this.m_data.slotIconUrl));
            this.m_icon.visible = true;
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name) as SeedItem;
            if(seedItem)
            {
               this.m_nameTextField.text = seedItem.friendlyTitle;
               mastery = seedItem.mastery;
               isMastered = Boolean(mastery) && mastery.hasAllMasteries();
               if(isMastered)
               {
                  (this.m_icon.element as MovieClip).alpha = 1;
                  this.m_checkWidget.visible = true;
                  this.m_lockWidget.visible = false;
                  seedCount = Global.player.countSeeds(seedItem.name);
                  this.m_tooltipTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_TooltipSeedCount",{"count":seedCount});
                  this.m_buyButton.visible = seedCount <= 0;
                  this.m_useButton.visible = seedCount > 0;
               }
               else
               {
                  activeSeedConfig = SeedDispenserManager.getActiveSeed(this.m_parentWindow.featureName);
                  isActiveSeed = this.m_data == activeSeedConfig;
                  if(isActiveSeed)
                  {
                     (this.m_icon.element as MovieClip).alpha = 1;
                     this.m_checkWidget.visible = false;
                     this.m_lockWidget.visible = false;
                     nextSeedConfig = SeedDispenserManager.getNextSeed(this.m_parentWindow.featureName,seedItem.name);
                     if(nextSeedConfig)
                     {
                        nextSeedItem = Global.farmGameSettingsManager.getFarmItemByName(nextSeedConfig.name);
                        this.m_tooltipTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_TooltipDefault",{"item":nextSeedItem.friendlyTitle});
                     }
                     else
                     {
                        this.m_tooltipTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_TooltipLast");
                     }
                     this.m_buyButton.visible = false;
                     this.m_useButton.visible = false;
                  }
                  else
                  {
                     (this.m_icon.element as MovieClip).alpha = 0.6;
                     this.m_checkWidget.visible = false;
                     this.m_lockWidget.visible = true;
                     previousSeedConfig = SeedDispenserManager.getPreviousSeed(this.m_parentWindow.featureName,seedItem.name);
                     if(previousSeedConfig)
                     {
                        previousSeedItem = Global.farmGameSettingsManager.getFarmItemByName(previousSeedConfig.name);
                        this.m_tooltipTextField.text = ZLocUtils.t("Dialogs","SeedDispenser_TooltipLocked",{"item":previousSeedItem.friendlyTitle});
                     }
                     this.m_buyButton.visible = false;
                     this.m_useButton.visible = false;
                  }
               }
            }
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var seedItem:SeedItem = null;
         if(this.m_useButton.enabled)
         {
            if(this.m_data)
            {
               seedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name) as SeedItem;
               if(seedItem)
               {
                  this.m_parentWindow.buySeed(seedItem);
               }
            }
         }
      }
      
      private function onUseButtonClick(event:MouseEvent) : void
      {
         var seedItem:SeedItem = null;
         if(this.m_useButton.enabled)
         {
            if(this.m_data)
            {
               seedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name) as SeedItem;
               if(seedItem)
               {
                  this.m_parentWindow.useSeed(seedItem);
               }
            }
         }
      }
   }
}

