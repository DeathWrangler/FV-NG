package Widgets.Slots.CaptureFeatureBuilding
{
   import Classes.util.ZLocUtils;
   import Managers.CaptureFeatureManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class CaptureFeatureBuildingSlot extends ZwSlotFrame
   {
      
      private var m_currentLevel:int = 1;
      
      private var m_captureCount:int = 0;
      
      private var m_levelTf:ZwTextField = null;
      
      private var m_gophersTf:ZwTextField = null;
      
      private var m_featureName:String = null;
      
      public function CaptureFeatureBuildingSlot(featureName:String, element:DisplayObject, currentLevel:int, captureCount:int)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_currentLevel = currentLevel;
         this.m_captureCount = captureCount;
         if(m_element.hasOwnProperty("level_tf"))
         {
            this.m_levelTf = addWidget(new ZwTextField(m_element.level_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("gophers_tf"))
         {
            this.m_gophersTf = addWidget(new ZwTextField(m_element.gophers_tf)) as ZwTextField;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var capturesToNextLevel:int = 0;
         super.populate(data);
         var prefix:String = CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName);
         this.m_levelTf.text = ZLocUtils.t("Dialogs",prefix + "_BuildingLevel",{"level":data.level + 1});
         this.m_levelTf.visible = true;
         if(data.newGophersCount == 1)
         {
            this.m_gophersTf.text = ZLocUtils.t("Dialogs",prefix + "_BuildingNewGophers_singular");
         }
         else
         {
            this.m_gophersTf.text = ZLocUtils.t("Dialogs",prefix + "_BuildingNewGophers",{"count":data.newGophersCount});
         }
         this.m_gophersTf.visible = true;
         if(data.level <= this.m_currentLevel)
         {
            m_element.check_mc.visible = true;
            m_element.locked_mc.visible = false;
         }
         else
         {
            m_element.check_mc.visible = false;
            m_element.locked_mc.visible = true;
            m_element.locked_mc.description_tf.visible = true;
            capturesToNextLevel = parseInt(data.capturedGophers);
            if(capturesToNextLevel == 1)
            {
               m_element.locked_mc.description_tf.text = ZLocUtils.t("Dialogs",prefix + "_BuildingDescription_singular");
            }
            else
            {
               m_element.locked_mc.description_tf.text = ZLocUtils.t("Dialogs",prefix + "_BuildingDescription",{"count":capturesToNextLevel});
            }
         }
         removeWidget(m_element.building_mc);
         addWidget(new FarmIcon(m_element.building_mc,data.image));
      }
   }
}

