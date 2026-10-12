package GameMode
{
   import AvatarMode.AMSeeder;
   import Classes.Avatar.FarmAvatar;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import flash.geom.Point;
   
   public class GMSeeder extends GMMultiPlotPlant
   {
      
      public function GMSeeder(seed:FarmItem, seeder:Seeder = null)
      {
         var seederTerrains:Array = null;
         var seedTerrains:Array = null;
         var i:int = 0;
         var j:int = 0;
         if(seeder == null)
         {
            seeder = Global.world.getEquipment(Seeder) as Seeder;
         }
         super(seed,seeder);
         if(seeder)
         {
            seederTerrains = seeder.getSupportedTerrainCodes();
            seedTerrains = seed.getTerrainCodes();
            m_arrAcceptableTerrain = [];
            for(i = 0; i < seederTerrains.length; i++)
            {
               for(j = 0; j < seedTerrains.length; j++)
               {
                  if(seederTerrains[i] == seedTerrains[j])
                  {
                     m_arrAcceptableTerrain.push(seedTerrains[j]);
                  }
               }
            }
         }
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         FarmStatsManager.count("use_vehicle","use_seeder",(m_actionSize.x * m_actionSize.y).toString());
         avatar.getStateMachine().addState(new AMSeeder(avatar,plots,m_equipment as Seeder,centerPos,m_seed),true);
      }
      
      public function get seeder() : Seeder
      {
         return m_equipment;
      }
   }
}

