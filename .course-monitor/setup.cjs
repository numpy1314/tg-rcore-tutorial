const fs=require('node:fs');const path=require('node:path');const {execFileSync}=require('node:child_process');
const root=path.resolve(__dirname,'..');
const git=(...args)=>execFileSync('git',['-C',root,...args],{encoding:'utf8'}).trim();
let previous='';try{previous=git('config','--get','core.hooksPath');}catch{}
if(previous && previous!=='.course-monitor/hooks')throw Error(`Existing core.hooksPath=${previous}; integrate the course pre-commit hook without replacing existing hooks.`);
if(!previous){const current=git('rev-parse','--git-path','hooks/pre-commit');if(fs.existsSync(path.resolve(root,current)))throw Error('Existing pre-commit hook found; manual hook chaining required.');}
git('config','--local','core.hooksPath','.course-monitor/hooks');
fs.chmodSync(path.join(__dirname,'hooks','pre-commit'),0o755);
for(const name of ['events','submissions'])fs.mkdirSync(path.join(root,'.ai',name),{recursive:true,mode:0o700});
console.log('Course log hooks installed. Open this repository in VS Code with Rewind Course 0.3.0.');
