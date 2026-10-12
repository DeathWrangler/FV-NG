package Display
{
   import Classes.EvolutionAnimal;
   import Classes.EvolutionAnimalCrate;
   import Classes.util.ZLocUtils;
   import Managers.EvolutionManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.EvolutionChoiceSlot;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class EvolutionChoiceDialog extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_FelineEvolution_choose.swf";
      
      private var m_animal:EvolutionAnimal;
      
      private var m_crate:EvolutionAnimalCrate;
      
      private var m_isCompleteNow:int;
      
      private var m_choices:Array;
      
      private var m_choiceSlot_0:EvolutionChoiceSlot;
      
      private var m_choiceSlot_1:EvolutionChoiceSlot;
      
      private var m_closeBtn:FarmButton;
      
      public function EvolutionChoiceDialog(animal:EvolutionAnimal, crate:EvolutionAnimalCrate = null, isCompleteNow:int = 0)
      {
         this.m_animal = animal;
         this.m_crate = crate;
         this.m_isCompleteNow = isCompleteNow;
         super(DIALOG_ASSET);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(new ZwBaseWidget(m_window["choose_mc"]));
         if(Boolean(m_window["choose_mc"]) && Boolean(m_window["choose_mc"]["close_bt"]))
         {
            this.m_closeBtn = new FarmButton(m_window["choose_mc"]["close_bt"],this.onCloseClick);
            addWidget(this.m_closeBtn);
         }
         if(Boolean(m_window["choose_mc"]) && Boolean(m_window["choose_mc"]["body_tf"]))
         {
            addWidget(new ZwTextField(m_window["choose_mc"]["body_tf"],ZLocUtils.t("Dialogs","EvolutionChoose")));
         }
         if(this.m_animal)
         {
            this.m_choices = EvolutionManager.instance.getAnimalEvolveOptions(this.m_animal);
         }
         else if(this.m_crate)
         {
            this.m_choices = EvolutionManager.instance.getBaseAnimals();
         }
         if(this.m_choices)
         {
            if(Boolean(m_window["choose_mc"]) && Boolean(m_window["choose_mc"]["chooseAnimal_0_mc"]))
            {
               this.m_choiceSlot_0 = new EvolutionChoiceSlot(m_window["choose_mc"]["chooseAnimal_0_mc"],this.m_animal,this.m_choices[0],this,this.m_crate,this.m_isCompleteNow);
               addWidget(this.m_choiceSlot_0);
            }
            if(Boolean(m_window["choose_mc"]) && Boolean(m_window["choose_mc"]["chooseAnimal_1_mc"]))
            {
               this.m_choiceSlot_1 = new EvolutionChoiceSlot(m_window["choose_mc"]["chooseAnimal_1_mc"],this.m_animal,this.m_choices[1],this,this.m_crate,this.m_isCompleteNow);
               addWidget(this.m_choiceSlot_1);
            }
         }
      }
      
      private function onCloseClick(event:MouseEvent) : void
      {
         if(this.m_closeBtn.hasEventListener(MouseEvent.CLICK))
         {
            this.m_closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         }
         if(!this.m_crate)
         {
            this.m_animal.startedCompletNowFlow = false;
         }
         super.close();
      }
   }
}

