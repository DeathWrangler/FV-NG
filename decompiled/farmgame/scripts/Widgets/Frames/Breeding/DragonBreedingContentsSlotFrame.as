package Widgets.Frames.Breeding
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.LabBuildingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import Widgets.Windows.MFSSevenDayLapsers;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DragonBreedingContentsSlotFrame extends AnimalBreedingContentsSlotFrame
   {
      
      protected static const DRAGON_SPELL_PKGS:Array = ["pkg_dragon_spells","pkg_dragon_spells_5","pkg_dragon_spells_10","pkg_dragon_spells_20","pkg_dragon_spells_30"];
      
      protected var m_buySpellsButton:ZwButton = null;
      
      public function DragonBreedingContentsSlotFrame(element:DisplayObject, animals:Array, mainWindow:BaseContentsWindow, buildingConfig:XML = null)
      {
         var buildingName:String = null;
         super(element,animals,mainWindow,buildingConfig);
         if(m_element.generic_bt != null)
         {
            buildingName = LabBuildingManager.getInstance().getLabNameFromConfig(buildingConfig);
            m_spellButton = addWidget(new FarmAnimatedTextButton(m_element.generic_bt,ZLocUtils.t("Dialogs",buildingName + "_generic_bt"),this.askForSpells)) as FarmAnimatedTextButton;
            m_spellButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","master_dragon")));
         }
         if(m_element.action3_bt != null)
         {
            this.m_buySpellsButton = addWidget(new FarmAnimatedTextButton(m_element.action3_bt,ZLocUtils.t("Dialogs","buy_spells"),this.onBuySpell)) as FarmAnimatedTextButton;
            this.m_buySpellsButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","buy_spells")));
         }
      }
      
      private function askForSpells(event:Event) : void
      {
         var itemName:String = "dragon_spells";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new MFSSevenDayLapsers(null,null,item,"animal_breeding_dragonlair_finished","dragon_lair",null),false);
      }
      
      private function onBuySpell(event:MouseEvent) : void
      {
         UI.displayMiniMarketDialog(DRAGON_SPELL_PKGS,UI.MARKET_CONTEXT_UNKNOWN,"",null,false,false,false,false,"",true);
      }
   }
}

