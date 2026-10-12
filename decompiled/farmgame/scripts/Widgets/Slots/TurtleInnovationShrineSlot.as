package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TurtleInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.TurtleInnovationShrineFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TurtleInnovationShrineSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_manager:TurtleInnovationManager;
      
      private var m_shrine:Object;
      
      private var m_shrineFrame:TurtleInnovationShrineFrame;
      
      private var m_harvestBt:FarmAnimatedTextButton;
      
      private var m_unlockBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_shrineNameTf:FarmTextField;
      
      private var m_consumableCountTf:FarmTextField;
      
      private var m_stoneMc:ZwWidget;
      
      private var m_isR2Unlocked:Boolean;
      
      private var m_countOfUnlockShrines:int;
      
      private var m_harvestTooltipText:String;
      
      public function TurtleInnovationShrineSlot(slotElement:DisplayObject, featureName:String, shrineFrame:TurtleInnovationShrineFrame)
      {
         super(slotElement);
         this.m_featureName = featureName;
         this.m_shrineFrame = shrineFrame;
         this.m_manager = TurtleInnovationManager.getInstance();
         this.m_isR2Unlocked = this.m_manager.isR2Unlocked();
         if(m_element.bt_harvest)
         {
            addWidget(this.m_harvestBt = new FarmAnimatedTextButton(m_element.bt_harvest,"Collect",this.onCollectClicked),false);
         }
         if(m_element.bt_FCready)
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element.bt_FCready,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Skip"),TurtleInnovationManager.getInstance().skipCost.toString(),this.onSkipClicked),false);
         }
         if(m_element.bt_seeTile)
         {
            addWidget(this.m_unlockBt = new FarmAnimatedTextButton(m_element.bt_seeTile,"Unlock",this.onUnlockClicked),false);
         }
         if(m_element.name_tf)
         {
            addWidget(this.m_shrineNameTf = new FarmTextField(m_element.name_tf,""),false);
         }
         if(m_element.count_tf)
         {
            addWidget(this.m_consumableCountTf = new FarmTextField(m_element.count_tf,""),false);
         }
         if(m_element["stone_mc"])
         {
            addWidget(this.m_stoneMc = new ZwWidget(m_element["stone_mc"]),false);
         }
      }
      
      private function onCollectClicked(event:Event) : void
      {
         if(this.m_harvestBt.enabled)
         {
            if(this.m_harvestBt.tooltip)
            {
               this.m_harvestBt.tooltip.release();
            }
            this.m_manager.harvestShrine(this.m_shrine);
            this.m_manager.m_turtleMainWindow.refreshWindow();
         }
      }
      
      private function onUnlockClicked(event:Event) : void
      {
         this.m_manager.highlightTiles(this.m_shrine.tileLocations);
         FarmStatsManager.count("tenguann_innovation_mainui","unlock_shrine_ui",this.m_shrine.name);
      }
      
      private function onSkipClicked(event:Event) : void
      {
         this.m_manager.skipHarvestTime(this.m_shrine.name);
         this.m_manager.m_turtleMainWindow.refreshWindow();
      }
      
      private function countNumberOfUnlockShrines() : int
      {
         var tile:String = null;
         var countOfUnlock:int = 0;
         if(this.m_shrine.name == "homeshrine")
         {
            if(!this.m_isR2Unlocked)
            {
               countOfUnlock = 1;
            }
            else
            {
               countOfUnlock = 2;
            }
         }
         else
         {
            for each(tile in this.m_shrine.tileLocations)
            {
               if(TurtleInnovationManager.getInstance().isTileUnlocked(tile))
               {
                  countOfUnlock++;
               }
            }
         }
         return countOfUnlock;
      }
      
      private function findTooltipTextForCollect(stoneFriendlyName:String) : String
      {
         var toolTipText:String = null;
         if(this.m_shrine.name == "homeshrine")
         {
            if(this.m_countOfUnlockShrines == 1)
            {
               this.m_harvestBt.attachTooltip(new FarmTextTooltip("Collect 1 stone at random"));
               toolTipText = "Collect 1 stone at random";
            }
            else
            {
               this.m_harvestBt.attachTooltip(new FarmTextTooltip("Collect 2 stones at random"));
               toolTipText = "Collect 2 stones at random";
            }
         }
         else if(this.m_shrine.name == "shrinelava")
         {
            toolTipText = "Collect 1 Fire and Earth Stone each";
         }
         else if(this.m_shrine.name == "shrinestorm")
         {
            toolTipText = "Collect 1 Water and Air Stone each";
         }
         else if(this.m_countOfUnlockShrines == 1)
         {
            this.m_harvestBt.attachTooltip(new FarmTextTooltip("Collect 1 " + stoneFriendlyName));
            toolTipText = "Collect 1 " + stoneFriendlyName;
         }
         else
         {
            toolTipText = "Collect 2 " + stoneFriendlyName + "s";
         }
         return toolTipText;
      }
      
      override public function populate(data:Object) : void
      {
         var stoneFriendlyName:String = null;
         var shrineMc:MovieClip = null;
         var toolTip:String = null;
         var isShrine1Unlocked:Boolean = false;
         var isShrine2Unlocked:Boolean = false;
         super.populate(data);
         this.m_shrine = data;
         var shrineFriendlyName:String = TurtleInnovationManager.getFriendlyName(this.m_shrine.name);
         stoneFriendlyName = TurtleInnovationManager.getFriendlyName(this.m_shrine.stoneName);
         if(this.m_stoneMc)
         {
            this.m_stoneMc.visible = true;
            if(this.m_stoneMc.tooltip)
            {
               this.m_stoneMc.detachTooltip();
            }
            this.m_stoneMc.attachTooltip(new FarmTextTooltip(TurtleInnovationManager.getFriendlyName(this.m_shrine.stoneName)));
         }
         this.m_countOfUnlockShrines = this.countNumberOfUnlockShrines();
         if(!(this.m_shrine.region == 2 && !this.m_isR2Unlocked))
         {
            if(this.m_shrineNameTf)
            {
               this.m_shrineNameTf.text = shrineFriendlyName;
               this.m_shrineNameTf.visible = true;
            }
            if(this.m_consumableCountTf)
            {
               this.m_consumableCountTf.text = "x" + this.m_manager.getConsumableItemCountByName(this.m_manager.getConsumableForShrine(this.m_shrine)).toString();
               this.m_consumableCountTf.visible = true;
            }
            if(TurtleInnovationManager.getInstance().isShrineReadyForHarvest(this.m_shrine))
            {
               this.m_harvestBt.visible = true;
               this.m_harvestBt.toggleClickableButton(true);
               this.m_skipBt.visible = false;
               this.m_harvestBt.detachTooltip();
               this.m_harvestTooltipText = this.findTooltipTextForCollect(stoneFriendlyName);
               this.m_harvestBt.attachTooltip(new FarmTextTooltip(this.m_harvestTooltipText));
            }
            else
            {
               this.m_skipBt.visible = true;
               this.m_harvestBt.visible = true;
               toolTip = FarmGameUtil.toFriendlyTime(this.m_manager.getTimeLeftForShrine(this.m_shrine)) + " remaining";
               if(this.m_harvestBt.tooltip)
               {
                  this.m_harvestBt.detachTooltip();
               }
               FarmGameUtil.disableButtonAndShowTooltip(this.m_harvestBt,toolTip);
            }
            shrineMc = null;
            switch(this.m_shrine.tileLocations.length)
            {
               case 0:
                  shrineMc = this.m_shrineFrame.element[this.m_shrine.movieClipName] as MovieClip;
                  shrineMc.visible = true;
                  shrineMc.gotoAndStop(1);
                  break;
               case 1:
                  if(this.m_manager.isTileUnlocked(this.m_shrine.tileLocations[0]))
                  {
                     if(this.m_unlockBt)
                     {
                        this.m_unlockBt.visible = false;
                     }
                  }
                  else
                  {
                     if(this.m_unlockBt)
                     {
                        this.m_unlockBt.visible = true;
                     }
                     this.m_harvestBt.toggleClickableButton(false);
                     this.m_skipBt.visible = false;
                  }
                  break;
               case 2:
                  shrineMc = this.m_shrineFrame.element[this.m_shrine.movieClipName] as MovieClip;
                  shrineMc.visible = true;
                  isShrine1Unlocked = this.m_manager.isTileUnlocked(this.m_shrine.tileLocations[0]);
                  isShrine2Unlocked = this.m_manager.isTileUnlocked(this.m_shrine.tileLocations[1]);
                  if(isShrine1Unlocked && isShrine2Unlocked)
                  {
                     shrineMc.gotoAndStop(3);
                  }
                  else if(isShrine1Unlocked || isShrine2Unlocked)
                  {
                     if(this.m_unlockBt)
                     {
                        this.m_unlockBt.visible = true;
                        if(this.m_unlockBt.tooltip)
                        {
                           this.m_unlockBt.detachTooltip();
                        }
                        this.m_unlockBt.attachTooltip(new FarmTextTooltip("Unlock 1 more tile to double the stones"));
                     }
                     (this.m_shrineFrame.element[this.m_shrine.movieClipName] as MovieClip).gotoAndStop(2);
                  }
                  else
                  {
                     shrineMc.gotoAndStop(1);
                     if(this.m_unlockBt)
                     {
                        this.m_unlockBt.visible = true;
                     }
                     if(this.m_unlockBt.tooltip)
                     {
                        this.m_unlockBt.detachTooltip();
                     }
                     this.m_unlockBt.attachTooltip(new FarmTextTooltip("Unlock tiles to start collecting stones!"));
                     this.m_harvestBt.visible = false;
                     if(this.m_harvestBt.tooltip)
                     {
                        this.m_harvestBt.detachTooltip();
                     }
                     FarmGameUtil.disableButtonAndShowTooltip(this.m_harvestBt,"Unlock tiles to start collecting!");
                     this.m_skipBt.visible = false;
                  }
            }
         }
      }
   }
}

