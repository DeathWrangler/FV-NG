package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.MutableAnimal;
   import Classes.MutableAnimalBaby;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BreedingRenameWindow extends FarmWindow
   {
      
      private static const ALLOWED_CHARS:String = "A-Z a-z 0-9";
      
      private static const DEFAULT_CHAR_LIMIT:int = 20;
      
      protected var m_worldObj:MapResource = null;
      
      protected var m_mutableAnimalState:MutableAnimalState = null;
      
      protected var m_babyFlag:Boolean = false;
      
      protected var m_nameText:FarmTextField = null;
      
      private var m_originalName:String;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      private var m_building:FeatureBuilding;
      
      private var m_closeCallback:Function;
      
      public function BreedingRenameWindow(worldObj:MapResource, mutableAnimalState:MutableAnimalState, babyFlag:Boolean = false, building:FeatureBuilding = null, closeCallback:Function = null)
      {
         this.m_worldObj = worldObj;
         this.m_mutableAnimalState = mutableAnimalState;
         this.m_babyFlag = babyFlag;
         this.m_building = building;
         this.m_closeCallback = closeCallback;
         super("assets/dialogs/FV_SheepPen_rename.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var customTitleKey:String = this.m_worldObj.getItem().className + "_Rename_Title";
         var titleKey:String = ZLocUtils.hasString("Dialogs",customTitleKey) ? customTitleKey : "AnimalBreeding_Rename_Title";
         addWidget(new ZwTextField(m_window.generic1_tf,ZLocUtils.t("Dialogs",titleKey)));
         m_window.name_tf.multiline = false;
         this.m_originalName = this.m_mutableAnimalState ? this.m_mutableAnimalState.name : "";
         this.m_nameText = new FarmTextField(m_window.name_tf,this.m_originalName);
         addWidget(this.m_nameText);
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onOkayClick));
         var scaleVal:Number = this.m_babyFlag ? 3.5 : 2.75;
         var metadata:String = this.m_mutableAnimalState ? this.m_mutableAnimalState.getPackedMutableState() : "";
         this.m_objectPreviewFrame = new ObjectPreviewFrame(m_window.icon_mc,this.m_worldObj.getItem(),null,[scaleVal],null,"frt_idle",metadata);
         if(this.m_mutableAnimalState)
         {
            if(this.m_objectPreviewFrame.mapResource is MutableAnimalBaby)
            {
               (this.m_objectPreviewFrame.mapResource as MutableAnimalBaby).setMutableAnimalState(this.m_mutableAnimalState);
            }
            else
            {
               (this.m_objectPreviewFrame.mapResource as MutableAnimal).setMutableAnimalState(this.m_mutableAnimalState);
            }
         }
         if(!this.m_babyFlag)
         {
            this.m_objectPreviewFrame.x += 10;
         }
         var featureName:String = Global.animalBreedingSettings.getFeatureNameByItem(this.m_worldObj.getItem().name);
         var characterLimit:int = Math.max(DEFAULT_CHAR_LIMIT,Number(Global.animalBreedingSettings.getFeatureConfigAttr(featureName,"maximumNameLength")));
         this.m_nameText.restrict(ALLOWED_CHARS,characterLimit);
         addWidget(this.m_objectPreviewFrame);
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_closeCallback = null;
         this.m_mutableAnimalState = null;
         this.m_nameText = null;
         this.m_objectPreviewFrame = null;
         this.m_worldObj = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(false);
         }
         super.onClose(event);
      }
      
      protected function onOkayClick(event:MouseEvent) : void
      {
         var renamed:Boolean = false;
         var metaHash:String = null;
         var newName:String = this.m_nameText.text;
         if(!FarmGameUtil.hasBadWord(newName))
         {
            renamed = false;
            if(newName != this.m_originalName)
            {
               renamed = true;
               metaHash = this.m_mutableAnimalState ? this.m_mutableAnimalState.getHashKey() : "";
               AnimalBreedingManager.getInstance().setAnimalName(this.m_worldObj.getItem().code,metaHash,newName,this.m_worldObj.getId(),this.m_building);
            }
            if(this.m_closeCallback != null)
            {
               this.m_closeCallback(renamed);
            }
            close();
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","AnimalBreeding_InvalidNameChoice"),0,null,"",true);
         }
      }
   }
}

