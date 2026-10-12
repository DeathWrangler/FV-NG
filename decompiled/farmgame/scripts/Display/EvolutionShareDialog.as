package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.EvolutionManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class EvolutionShareDialog extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_FelineEvolution_share.swf";
      
      private var m_animal:String;
      
      private var m_isElder:Boolean;
      
      private var m_isCrate:Boolean;
      
      private var m_sourceAnimalFriendlyName:String;
      
      public function EvolutionShareDialog(animal:String, isElder:Boolean = false, sourceAnimalFriendlyName:String = "", isCrate:Boolean = false)
      {
         this.m_animal = animal;
         this.m_isElder = isElder;
         this.m_isCrate = isCrate;
         this.m_sourceAnimalFriendlyName = sourceAnimalFriendlyName;
         super(DIALOG_ASSET);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var animalItem:FarmItem = null;
         var crateItem:FarmItem = null;
         super.onLoadComplete(event);
         if(m_window)
         {
            if(m_window["title_tf"])
            {
               addWidget(new ZwTextField(m_window["title_tf"],"Congrats!"));
            }
            if(m_window["icon_mc"])
            {
               if(this.m_animal)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     animalItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_animal);
                  }
                  else
                  {
                     animalItem = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(this.m_animal));
                  }
                  if(animalItem)
                  {
                     addWidget(new ObjectPreviewFrame(m_window["icon_mc"],animalItem));
                  }
               }
            }
            if(this.m_isCrate && Boolean(m_window["bitmap_mc"]))
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  crateItem = Global.farmGameSettingsManager.getFarmItemByName("deco_animalcrate2");
               }
               else
               {
                  crateItem = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName("deco_animalcrate2"));
               }
               addWidget(new FarmIcon(m_window["bitmap_mc"],crateItem.iconUrl));
            }
            if(Boolean(m_window["item_tf"]) && Boolean(m_window["share_tf"]) && Boolean(this.m_animal))
            {
               if(this.m_isElder)
               {
                  addWidget(new ZwTextField(m_window["item_tf"],ZLocUtils.t("Dialogs","EvolutionFullyGrown",{"animalName":ZLocUtils.tk_pk_asTitle(animalItem.friendlyName)})));
                  addWidget(new ZwTextField(m_window["share_tf"],ZLocUtils.t("Dialogs","EvolutionFullyGrownShare")));
               }
               else
               {
                  addWidget(new ZwTextField(m_window["item_tf"],ZLocUtils.t("Dialogs","EvolutionAnimalGrew",{"animalName":ZLocUtils.tk_pk_asTitle(animalItem.friendlyName)})));
                  addWidget(new ZwTextField(m_window["share_tf"],ZLocUtils.t("Dialogs","EvolutionAnimalGrewShare")));
               }
            }
            else if(Boolean(m_window["item_tf"]) && this.m_isCrate)
            {
               addWidget(new ZwTextField(m_window["item_tf"],ZLocUtils.t("Dialogs","EvolutionCratePlace")));
               addWidget(new ZwTextField(m_window["share_tf"],ZLocUtils.t("Dialogs","EvolutionAnimalGrewShare")));
            }
            if(Boolean(m_window["share_bt"] && m_window["place_bt"]) && Boolean(this.m_animal) && this.m_isElder)
            {
               (m_window["place_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionShareAndPlace");
               (m_window["share_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionPlace");
               addWidget(new FarmAnimatedButton(m_window["place_bt"],this.shareButtonCallback));
               addWidget(new FarmAnimatedButton(m_window["share_bt"],this.placeButtonCallback));
            }
            else if(m_window["place_bt"])
            {
               (m_window["place_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionShare");
               addWidget(new FarmAnimatedButton(m_window["place_bt"],this.shareButtonCallback));
            }
         }
      }
      
      private function placeButtonCallback(event:MouseEvent) : void
      {
         close();
      }
      
      private function shareButtonCallback(event:MouseEvent) : void
      {
         if(this.m_isCrate)
         {
            EvolutionManager.instance.postFeed(EvolutionManager.OPEN_CRATE_FEED);
         }
         else
         {
            EvolutionManager.instance.postFeed(EvolutionManager.EVOLVE_ANIMAL_FEED);
         }
         close();
      }
   }
}

