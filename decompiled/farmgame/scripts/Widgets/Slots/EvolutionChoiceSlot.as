package Widgets.Slots
{
   import Classes.EvolutionAnimal;
   import Classes.EvolutionAnimalCrate;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.EvolutionChoiceDialog;
   import Managers.EvolutionManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class EvolutionChoiceSlot extends ZwSlotFrame
   {
      
      private var m_animal:EvolutionAnimal;
      
      private var m_crate:EvolutionAnimalCrate;
      
      private var m_isCompleteNow:int;
      
      private var m_item:FarmItem;
      
      private var m_containingWindow:EvolutionChoiceDialog;
      
      public function EvolutionChoiceSlot(element:MovieClip, evoAnimal:EvolutionAnimal, animalOption:String, containingWindow:EvolutionChoiceDialog, crate:EvolutionAnimalCrate = null, isCompleteNow:int = 0)
      {
         super(element);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(animalOption);
         }
         else
         {
            this.m_item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(animalOption));
         }
         this.m_animal = evoAnimal;
         this.m_crate = crate;
         this.m_isCompleteNow = isCompleteNow;
         this.m_containingWindow = containingWindow;
         if(Boolean(m_element["animal_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.animal_mc,this.m_item));
         }
         if(Boolean(m_element["animalTitle_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_element.animalTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         }
         if(m_element["use_bt"])
         {
            if(m_element["use_bt"]["generic_tf"])
            {
               (m_element["use_bt"]["generic_tf"] as TextField).text = "Choose";
            }
            addWidget(new FarmAnimatedButton(m_element.use_bt,this.chooseButtonClicked));
         }
      }
      
      private function chooseButtonClicked(event:Event) : void
      {
         if(this.m_isCompleteNow != 0 && Boolean(this.m_animal))
         {
            EvolutionManager.instance.evolveToNextLevelFromCompleteNow(this.m_animal,this.m_item.name);
            Global.player.cash -= this.m_isCompleteNow;
            this.m_animal.toggleMenu(false);
            this.m_containingWindow.close();
         }
         else if(this.m_animal)
         {
            EvolutionManager.instance.evolveToNextLevel(this.m_animal,this.m_item.name);
            this.m_animal.toggleMenu(false);
            this.m_containingWindow.close();
         }
         else if(this.m_crate)
         {
            EvolutionManager.instance.evolveToNextLevelFromCrate(this.m_crate,this.m_item.name);
            this.m_crate.toggleMenu(false);
            this.m_containingWindow.close();
         }
      }
   }
}

