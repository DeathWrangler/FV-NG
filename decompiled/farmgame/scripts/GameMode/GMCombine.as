package GameMode
{
   import AvatarMode.AMCombine;
   import Classes.Avatar.FarmAvatar;
   import Classes.Combine;
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import flash.geom.Point;
   
   public class GMCombine extends GMMultiPlotCombine
   {
      
      public function GMCombine(seed:FarmItem, combine:Combine = null)
      {
         if(combine == null)
         {
            combine = Global.world.getEquipment(Combine) as Combine;
         }
         super(seed,combine);
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         FarmStatsManager.count("use_vehicle","use_combine",(m_actionSize.x * m_actionSize.y).toString());
         avatar.getStateMachine().addState(new AMCombine(avatar,plots,m_equipment as Combine,centerPos,m_seed),true);
      }
      
      public function get combine() : Combine
      {
         return m_equipment as Combine;
      }
   }
}

