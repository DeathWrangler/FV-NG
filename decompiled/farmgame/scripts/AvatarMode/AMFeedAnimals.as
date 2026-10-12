package AvatarMode
{
   import Classes.AnimalStorageBuilding;
   import Classes.Avatar.FarmAvatar;
   import Classes.Building;
   import Classes.HarvestableResource;
   import Engine.Managers.SoundManager;
   
   public class AMFeedAnimals extends AMBuildingInteraction
   {
      
      public function AMFeedAnimals(avatar:FarmAvatar, building:AnimalStorageBuilding)
      {
         super(avatar,building as Building);
      }
      
      override protected function doAction() : void
      {
         (m_targetBuilding as AnimalStorageBuilding).feedAnimals();
      }
      
      override protected function getProgressText() : String
      {
         return m_targetBuilding.getActionText();
      }
      
      override public function added() : void
      {
         super.added();
         (m_targetBuilding as AnimalStorageBuilding).setActionState(AnimalStorageBuilding.IS_FEEDING);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(!this.conditionallyPath() || this.m_actionStarted)
         {
            m_playOnReenter = false;
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(m_playOnReenter && this.m_actionStarted)
         {
            SoundManager.chooseAndPlaySound(["plow1","plow2","plow3"]);
         }
      }
      
      override public function removed() : void
      {
         super.removed();
         (m_targetBuilding as AnimalStorageBuilding).setActionState(HarvestableResource.IS_RESTING);
      }
   }
}

