// Stand-in for Firebase, with made-up test characters, so tools/check can load the site without the real database.
const now=Date.now(),ago=d=>new Date(now-d*864e5).toISOString();
const ME="uid-clark";
const seed={
 members:{
  [ME]:{first:"Test",last:"Test",char:"Clark Clark",race:"Troll",cls:"Rogue",role:"DPS",level:24,tz:"AWST",dst:false,joined:"2026-11-05",spec:"Combat",armory:{at:ago(0.05),url:"https://example.com",guild:"Blood and Tears",level:24,spec:"Combat",render:"https://render.worldofwarcraft.com/forever-us/character/91/181851-main-raw.png",avatar:"https://render.worldofwarcraft.com/forever-us/character/91/181851-avatar.jpg"},profs:{Mining:112,Engineering:98,"First Aid":150,Cooking:60,Fishing:40,Lockpicking:85},
    goals:[{id:"a1",kind:"dungeon",t:"Shadowfang Keep",range:"20–26",lfg:true,done:false},{id:"a2",kind:"item",t:"Buzzer Blade",url:"https://www.wowhead.com/classic/item=2169/buzzer-blade",lfg:false,done:false},{id:"a3",kind:"bg",t:"Warsong Gulch",lfg:true,done:false},{id:"a4",kind:"dungeon",t:"Ragefire Chasm",range:"13–18",lfg:false,done:true}],
    journey:[{t:"Reached level 24",at:ago(1)},{t:"Finished Ragefire Chasm",at:ago(2)}],avail:{E:[0,1,2,3],L:[0,1,2,3,4],A:[5,6]},createdAt:ago(6),updatedAt:ago(1),player:"Test Player"},
  u2:{owners:["someone-else"],first:"Grimtusk",last:"Ironjaw",char:"Grimtusk Ironjaw",race:"Orc",cls:"Warrior",role:"Tank",level:34,tz:"AEST",dst:true,profs:{Mining:165,Blacksmithing:150,"First Aid":175,Cooking:120},goals:[{id:"b1",kind:"dungeon",t:"Scarlet Monastery: Graveyard",range:"30–38",lfg:true,done:false,at:ago(0.2)}],journey:[{t:"Reached level 34",at:ago(0.5),from:30},{t:"Got Wolfmaster Cape",at:ago(3)}],avail:{E:[4,5],L:[5]},createdAt:ago(8),updatedAt:ago(0)},
  u3:{first:"Moonhoof",last:"Stillwater",char:"Moonhoof Stillwater",race:"Tauren",cls:"Druid",role:"Healer",level:22,tz:"AEST",dst:true,profs:{Herbalism:155,Alchemy:140},goals:[],wishlist:[{id:"w1",url:"https://www.wowhead.com/classic/item=6314/wolfmaster-cape",name:"Wolfmaster Cape",from:"Shadowfang Keep"}],avail:{E:[0,1],L:[1,2]},createdAt:ago(7),updatedAt:ago(3)},
  u4:{char:"Drekka Stormcall",race:"Troll",cls:"Shaman",role:"Healer",level:60,profs:{Skinning:140,Leatherworking:125,Fishing:300},goals:[{t:"Reach level 60",done:false},{t:"Max Cooking",done:true},{t:"Max fishing",done:false}],owners:["dev-1"],ownerReq:{uid:"new-phone",at:new Date(Date.now()-36e5).toISOString()},ownerReq:{uid:"new-phone",at:new Date(Date.now()-36e5).toISOString()},updatedAt:ago(5)},
  u5:{showoff:{name:"Solo killed Hogger at level 9",at:ago(0.1)},first:"Rotgut",last:"Ashvein",char:"Rotgut Ashvein",race:"Undead",cls:"Mage",role:"DPS",level:19,tz:"ACST",dst:true,profs:{Tailoring:130,Enchanting:110,Comprehension:45},crafts:[{id:"c1",url:"https://www.wowhead.com/classic/item=5762/red-linen-bag",name:"Red Linen Bag",prof:"Tailoring"}],goals:[{id:"c1",kind:"bg",t:"Warsong Gulch",lfg:true,done:false}],createdAt:ago(4),updatedAt:ago(2)}
 },
 alts:{al1:{first:"Sparkfuse",last:"Copperwick",char:"Sparkfuse Copperwick",race:"Skyborne",cls:"Mage",role:"DPS",level:8,owner:ME,profs:{Tailoring:30},goals:[],createdAt:ago(2),updatedAt:ago(2)}},
 orders:{o1:{url:"https://www.wowhead.com/classic/item=858/lesser-healing-potion",name:"Lesser Healing Potion",qty:10,prof:"Alchemy",cp:0,mats:false,from:"u4",maker:null,done:false,createdAt:ago(1)},
   o2:{url:"https://www.wowhead.com/classic/item=4360/rough-copper-bomb",name:"Rough Copper Bomb",qty:20,prof:"Engineering",cp:4005,mats:true,from:"u2",maker:null,done:false,createdAt:ago(0)},
   o3:{url:"https://www.wowhead.com/classic/item=5762/red-linen-bag",name:"Red Linen Bag",qty:2,prof:"Tailoring",cp:124005,mats:false,from:ME,maker:"u5",done:false,createdAt:ago(2)}},
 joins:{j1:{goal:"members/u2/b1",uid:"u3"},j2:{goal:"members/"+ME+"/a1",uid:"u2"}},
 events:{e1:{title:"SFK run",type:"dungeon",dungeon:"Shadowfang Keep",when:new Date(now+2*864e5).toISOString(),notes:"Bring pots",by:"u2"}},
 rsvps:{r1:{event:"e1",member:"u2",status:"going"},r2:{event:"e1",member:"u3",status:"going"}},
 guild:{info:{discord:"https://discord.gg/abc123",gm:"Grimtusk Ironjaw"},roster:{at:ago(0),members:[{name:"Clark Clark",level:24,rank:2},{name:"Grimtusk Ironjaw",level:34,rank:0},{name:"Moonhoof Stillwater",level:22,rank:2},{name:"Sparkfuse Copperwick",level:8,rank:2},{name:"Rotgut Ashvein",level:19,rank:2}]}}
};
// Armory data for the new features.
{const R="https://render.worldofwarcraft.com/forever-us/";const hrs=x=>new Date(now-x*36e5).toISOString();
 const T=(n,r,d)=>({id:n.length,name:n,rank:r,icon:R+"icons/56/"+(136000+n.length)+".jpg",desc:d});
 Object.assign(seed.members[ME].armory,{updated:hrs(7),bg:"https://render.worldofwarcraft.com/profile-backgrounds/v2/armory_bg_race_troll.jpg",
   talents:[{name:"Combat",points:16,active:true,icon:R+"icons/56/132090.jpg",talents:[T("Efficient Strikes",2,"Reduces the Energy cost of Sinister Strike."),T("Lightning Reflexes",3,"Increases your Dodge chance by 3%."),T("Precision",3,"Increases your chance to hit by 3%."),T("Deflection",1,"Parry +1%."),T("Riposte",1,"A strike that becomes active after parrying."),T("Weapon Expertise",1,"Reduces chance to be dodged."),T("Endurance",2,"Reduces cooldowns."),T("Hack and Slash",3,"Daggers: +3% crit.")]},
     {name:"Assassination",points:5,active:false,icon:R+"icons/56/132292.jpg",talents:[T("Malice",5,"Increases your critical strike chance by 5%.")]}],
   stats:{health:1218,energy:100,strength:58,agility:118,intellect:28,stamina:78,spirit:40,"critical-strike":10.62,damage:[33.9,47.9],"attack-power":266,"attack-speed":2.6,"attack-dps":27.57,"spell-power":0,"mana-regen":0,armor:845,dodge:12.39,parry:5,block:0},
   hk:42,rank:1,hkWeek:{wk:"2000-01-03",base:0}});
 seed.members[ME].gear={Chest:{id:"6471",name:"Blackened Defias Armor",q:2,iconUrl:"",slot:"Chest"},Waist:{id:"10413",name:"Gloves of the Fang",q:3,iconUrl:"",slot:"Waist"},"Main hand":{id:"2169",name:"Buzzer Blade",q:3,iconUrl:"",slot:"One-Hand"}};
 seed.members.u2.armory={at:hrs(.5),updated:hrs(30),level:34,hk:340,rank:3,hkWeek:{wk:"WEEK",base:300},render:R+"character/1/2-main-raw.png",bg:"https://render.worldofwarcraft.com/profile-backgrounds/v2/armory_bg_race_orc.jpg"};
 seed.members.u3.armory={at:hrs(.5),updated:hrs(24*20),level:22,hk:5,rank:0,hkWeek:{wk:"WEEK",base:5}};
}
{const d=new Date(Date.now()+8*36e5);d.setUTCDate(d.getUTCDate()-(d.getUTCDay()+6)%7);const wk=d.toISOString().slice(0,10);for(const m of Object.values(seed.members))if(m.armory&&m.armory.hkWeek&&m.armory.hkWeek.wk==="WEEK")m.armory.hkWeek.wk=wk}
const store=window.__seed||JSON.parse(JSON.stringify(seed));window.__store=store;window.__log=[];
if(window.__seedPatch){store.guild=store.guild||{};store.guild.firsts=window.__seedPatch}
if(window.__streaks){store.guild=store.guild||{};store.guild.streaks=window.__streaks}
if(window.__officers){store.guild=store.guild||{};store.guild.officers=window.__officers}
if(window.__helpers){store.guild=store.guild||{};store.guild.helpers=window.__helpers}
const subs=[];
const notify=()=>setTimeout(()=>subs.forEach(s=>s()),0);
export const initializeApp=()=>({});export const getAuth=()=>({});export class GoogleAuthProvider{}
export const signInWithPopup=async()=>{};export const signInWithRedirect=async()=>{};export const signOut=async()=>{};
let authCb;export const onAuthStateChanged=(a,cb)=>{authCb=cb;setTimeout(()=>cb(null),0)};
export const signInAnonymously=async()=>{if(window.__anonOff){const e=new Error("x");e.code="auth/operation-not-allowed";throw e}setTimeout(()=>authCb({uid:window.__dev||"dev-1",isAnonymous:true}),0)};
export const getDoc=async ref=>{const d=(store[ref.c]||{})[ref.id];return{exists:()=>!!d,data:()=>d}};
export const initializeFirestore=()=>({});export const persistentLocalCache=()=>({});export const persistentMultipleTabManager=()=>({});
export const collection=(db,c)=>({c});
let n=0;export const doc=(db,c,id)=>typeof db==="object"&&db&&db.c?{c:db.c,id:"new"+(++n)}:{c,id};
export const deleteField=()=>"__DEL__";
export const onSnapshot=(ref,opts,cb,err)=>{if(typeof opts==="function"){err=cb;cb=opts}
 const fire=()=>{const col=store[ref.c]||{};if(ref.id){const d=col[ref.id];cb({exists:()=>!!d,data:()=>d})}else cb({docs:Object.entries(col).map(([id,d])=>({id,data:()=>d})),metadata:{hasPendingWrites:false}})};
 subs.push(fire);setTimeout(fire,0);return()=>{}};
const put=(ref,d)=>{(store[ref.c]=store[ref.c]||{})[ref.id]=d;window.__log.push(["set",ref.c,ref.id,d]);notify();return Promise.resolve()};
export const setDoc=(ref,d)=>put(ref,JSON.parse(JSON.stringify(d)));
export const updateDoc=(ref,d)=>{const cur={...(store[ref.c][ref.id]||{})};for(const[k,v]of Object.entries(d)){if(v==="__DEL__")delete cur[k];else cur[k]=v}window.__log.push(["update",ref.c,ref.id,d]);store[ref.c][ref.id]=JSON.parse(JSON.stringify(cur));notify();return Promise.resolve()};
export const deleteDoc=ref=>{delete store[ref.c][ref.id];window.__log.push(["delete",ref.c,ref.id]);notify();return Promise.resolve()};
export const addDoc=(ref,d)=>put({c:ref.c,id:"new"+(++n)},JSON.parse(JSON.stringify(d)));
const blobs={};
export const getStorage=()=>({});export const ref=(s,p)=>({p});
export const uploadBytes=async(r,b)=>{blobs[r.p]=URL.createObjectURL(b);window.__uploads=(window.__uploads||[]).concat([[r.p,b.size,b.type]])};
export const getDownloadURL=async r=>blobs[r.p];export const deleteObject=async r=>{delete blobs[r.p]};
export const getFunctions=()=>({});
const CAT=[{id:"6471",name:"Blackened Defias Armor",q:2,icon:"",slot:"Chest",cls:"Armor",sub:"Leather"},{id:"4238",name:"Linen Bag",q:1,icon:"",slot:"",cls:"Container",sub:"Bag"},{id:"10399",name:"Blackened Defias Leggings",q:2,icon:"",slot:"Legs"},{id:"5191",name:"Cruel Barb",q:3,icon:"inv_sword_04",slot:"Two-Hand"},{id:"2169",name:"Buzzer Blade",q:3,icon:"",slot:"One-Hand"}];
export const httpsCallable=(f,name)=>async d=>{window.__calls=(window.__calls||[]).concat([[name,d]]);
 if(name==="scribeKey")return{data:{key:"TESTKEY_abcdefghijklmnopqrstuvwx"}};
 if(name==="saveSiteData")return{data:{ok:true}};
 if(name==="itemSearch")return{data:{items:CAT.filter(c=>c.name.toLowerCase().includes(d.q.toLowerCase()))}};
 if(name==="itemLookup"&&Array.isArray(d.names)){store.guild=store.guild||{};const cur=(store.guild.itemIds&&store.guild.itemIds.items)||{},found={};
   for(const n of d.names){const k=n.toLowerCase();if(/^enchant /.test(k))continue;found[k]=k==="meathook slicer"?[99001,3]:[0,0,Date.now()]}
   store.guild.itemIds={items:{...cur,...found}};notify();return{data:{found}}}
 if(name==="itemLookup")return{data:{id:d.id,name:"Looked Up Item",q:4,icon:"",slot:"Head"}};
 if(name==="armoryLookup")return{data:/zug/i.test(d.name)?{found:true,first:"Zugzug",last:"Bonecrusher",level:27,cls:"Warrior",race:"Orc",spec:"Protection",profs:{Mining:120,Blacksmithing:110,Cooking:40,"First Aid":75},guild:"Blood and Tears"}:{found:false}};
 if(name==="privacyCleanup")return{data:d&&d.run?{removed:true}:{fields:{notes:2,wishlist:1},collections:{lfg:4},links:1}};
 if(name==="armorySync")return{data:{found:true,changed:[],kept:["gear"],updated:new Date(Date.now()-7*36e5).toISOString()}};};
window.__notify=()=>notify();

export const initializeAppCheck=()=>({});export class ReCaptchaEnterpriseProvider{constructor(k){this.k=k}}
export const increment=n=>n;export const documentId=()=>"__id";export const where=(...a)=>a;export const query=(c)=>c;
export const getDocs=async ref=>({docs:Object.entries(store[ref.c]||{}).map(([id,d])=>({id,data:()=>d}))});
