package Widgets.Slots.Breeding
{
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.LabBuildingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import Widgets.Windows.MFSSevenDayLapsers;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class DragonContentsSlot extends AnimalBreedingContentsSlot
   {
      
      private const CAST_SPELL:String = "cast_spell";
      
      public function DragonContentsSlot(element:DisplayObject, parentWindow:BaseContentsWindow, labBuildingConfig:XML = null)
      {
         var buildingName:String = null;
         var callback:Function = null;
         super(element,parentWindow,labBuildingConfig);
         if(m_element.hasOwnProperty("action_bt"))
         {
            if(labBuildingConfig)
            {
               buildingName = LabBuildingManager.getInstance().getLabNameFromConfig(labBuildingConfig);
               callback = this[LabBuildingManager.getInstance().getActionButtonName(buildingName)];
               m_secondaryActionButton = addWidget(new FarmAnimatedTextButton(m_element.action_bt,ZLocUtils.t("Dialogs",buildingName + "_action_bt"),callback)) as ZwButton;
               if(!SoundManager.isMuted())
               {
                  if(!SoundManager.getSoundById(this.CAST_SPELL))
                  {
                     SoundManager.addSound(this.CAST_SPELL,Global.getAssetURL("assets/sounds/dragonlair/sfx_dragonspell.mp3"),false);
                  }
               }
            }
            else
            {
               m_secondaryActionButton = addWidget(new FarmAnimatedTextButton(m_element.market_bt,ZLocUtils.t("Dialogs","Market"),onClickMarket)) as ZwButton;
            }
         }
      }
      
      private function onCastSpell(event:MouseEvent) : void
      {
         var itemCode:String = null;
         var dragonSpell:FarmItem = null;
         var item:FarmItem = null;
         pause();
         var itemName:String = "dragon_spells";
         var numberOfSpells:int = Global.player.getGiftCountForItem(itemName);
         if(numberOfSpells > 0)
         {
            itemCode = m_farmItem.code;
            dragonSpell = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            TransactionManager.addTransaction(new TGenericTransaction("FarmService","incrementMasteryByCode",this.refreshMasteryFrame,[itemCode,dragonSpell.code]));
         }
         else
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            UI.displayPopup(new MFSSevenDayLapsers(null,null,item,"animal_breeding_dragonlair_finished","dragon_lair",null),false);
            unpause();
         }
      }
      
      private function refreshMasteryFrame(result:Object) : void
      {
         var mastery:Mastery = null;
         var levelProgress:int = 0;
         var masteryCurrentViewLevel:int = 0;
         var currentProgress:int = 0;
         var userFacingMasteryLevel:int = 0;
         if(result.hasOwnProperty("newMasteryLevel"))
         {
            if(m_masteryFrame != null)
            {
               if(m_farmItem is HarvestableItem && (m_farmItem as HarvestableItem).hasMastery)
               {
                  mastery = (m_farmItem as HarvestableItem).mastery;
                  levelProgress = 0;
                  masteryCurrentViewLevel = mastery.currentLevel;
                  if(masteryCurrentViewLevel >= 0)
                  {
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        levelProgress = int(mastery.levelsData[masteryCurrentViewLevel].getInt("count"));
                     }
                     else
                     {
                        levelProgress = int(mastery.levels[masteryCurrentViewLevel].@count);
                     }
                  }
                  currentProgress = int(result.newMasteryLevel) - levelProgress;
                  userFacingMasteryLevel = masteryCurrentViewLevel + 1;
                  m_masteryFrame.update(userFacingMasteryLevel,currentProgress,mastery.totalCropsNeeded);
                  m_masteryFrame.visible = true;
                  if(m_secondaryActionButton)
                  {
                     m_secondaryActionButton.visible = userFacingMasteryLevel < MarketSlotMasteryFrame.MAX_LEVEL;
                  }
               }
               else
               {
                  m_masteryFrame.visible = false;
                  if(m_secondaryActionButton)
                  {
                     m_secondaryActionButton.visible = false;
                  }
               }
               m_marketButton.visible = false;
            }
         }
         if(result.hasOwnProperty("storageData"))
         {
            Global.player.refreshGiftBox(result.storageData);
         }
         unpause();
         SoundManager.playSound(this.CAST_SPELL);
      }
   }
}

